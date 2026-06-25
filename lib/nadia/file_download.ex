defmodule Nadia.FileDownload do
  @moduledoc false

  alias Nadia.Client
  alias Nadia.HTTPClient
  alias Nadia.HTTPDownloadRequest
  alias Nadia.HTTPDownloadResponse
  alias Nadia.Model.Error
  alias Nadia.Model.File, as: TelegramFile

  @chunk_size 64 * 1024
  @allowed_options [:overwrite, :receive_timeout]

  @spec download(Client.t(), binary | TelegramFile.t(), Path.t(), non_neg_integer, keyword) ::
          {:ok, Path.t()} | {:error, Error.t()}
  def download(%Client{} = client, source, destination, max_bytes, options) do
    with {:ok, options} <- validate_options(destination, max_bytes, options),
         :ok <- validate_destination(destination, options.overwrite),
         {:ok, file} <- resolve_file(client, source),
         :ok <- validate_file(file, max_bytes),
         {:ok, source_kind} <- source_kind(client.file_mode, file.file_path),
         {:ok, result} <-
           write_download(client, file, source_kind, destination, max_bytes, options) do
      {:ok, result}
    else
      {:error, %Error{} = error} -> {:error, error}
      {:error, reason} -> {:error, %Error{reason: {:download, reason}}}
    end
  end

  defp validate_options(destination, max_bytes, options)
       when is_binary(destination) and byte_size(destination) > 0 and is_integer(max_bytes) and
              max_bytes >= 0 and is_list(options) do
    if Keyword.keyword?(options) and
         Enum.all?(Keyword.keys(options), &(&1 in @allowed_options)) do
      overwrite = Keyword.get(options, :overwrite, false)
      receive_timeout = Keyword.get(options, :receive_timeout)

      cond do
        not is_boolean(overwrite) ->
          {:error, :invalid_overwrite}

        not is_nil(receive_timeout) and
            (not is_integer(receive_timeout) or receive_timeout < 0) ->
          {:error, :invalid_receive_timeout}

        true ->
          {:ok, %{overwrite: overwrite, receive_timeout: receive_timeout}}
      end
    else
      {:error, :invalid_options}
    end
  end

  defp validate_options(destination, _max_bytes, _options)
       when not is_binary(destination) or destination == "",
       do: {:error, :invalid_destination}

  defp validate_options(_destination, max_bytes, _options)
       when is_integer(max_bytes) and max_bytes >= 0,
       do: {:error, :invalid_options}

  defp validate_options(_destination, _max_bytes, _options), do: {:error, :invalid_max_bytes}

  defp validate_destination(_destination, true), do: :ok

  defp validate_destination(destination, false) do
    case File.lstat(destination) do
      {:ok, _stat} -> {:error, :destination_exists}
      {:error, :enoent} -> :ok
      {:error, reason} -> {:error, {:filesystem, :destination, reason}}
    end
  end

  defp resolve_file(_client, %TelegramFile{} = file), do: {:ok, file}

  defp resolve_file(client, file_id) when is_binary(file_id) and byte_size(file_id) > 0,
    do: Nadia.get_file(client, file_id)

  defp resolve_file(_client, _source), do: {:error, :invalid_file}

  defp validate_file(%TelegramFile{file_path: path, file_size: size}, max_bytes) do
    cond do
      not is_binary(path) or path == "" -> {:error, :file_path_unavailable}
      not is_nil(size) and (not is_integer(size) or size < 0) -> {:error, :invalid_file_size}
      is_integer(size) and size > max_bytes -> {:error, {:file_too_large, size, max_bytes}}
      true -> :ok
    end
  end

  defp source_kind(:remote, path) do
    if Path.type(path) == :relative,
      do: {:ok, {:remote, path}},
      else: {:error, :absolute_file_path_not_allowed}
  end

  defp source_kind(:local, path) do
    if Path.type(path) == :absolute,
      do: {:ok, {:local, path}},
      else: {:error, :local_file_path_expected}
  end

  defp write_download(client, file, source_kind, destination, max_bytes, options) do
    with {:ok, temp_path, io} <- open_temp(destination) do
      result =
        try do
          with {:ok, bytes} <-
                 transfer(client, file, source_kind, io, max_bytes, options.receive_timeout),
               :ok <- sync(io),
               :ok <- verify_temp_size(temp_path, bytes, max_bytes) do
            {:ok, bytes}
          end
        rescue
          _error -> {:error, :transport_error}
        catch
          _kind, _reason -> {:error, :transport_error}
        after
          File.close(io)
        end

      case result do
        {:ok, _bytes} -> publish(temp_path, destination, options.overwrite)
        {:error, reason} -> cleanup_error(temp_path, reason)
      end
    end
  end

  defp open_temp(destination) do
    directory = Path.dirname(destination)
    basename = Path.basename(destination)

    temp_path =
      Path.join(
        directory,
        ".#{basename}.nadia-download-#{System.unique_integer([:positive, :monotonic])}"
      )

    case File.open(temp_path, [:write, :binary, :exclusive]) do
      {:ok, io} -> {:ok, temp_path, io}
      {:error, reason} -> {:error, {:filesystem, :open_temp, reason}}
    end
  end

  defp transfer(_client, file, {:local, path}, io, max_bytes, _receive_timeout) do
    with {:ok, %File.Stat{type: :regular, size: size}} <- stat_regular(path),
         :ok <- preflight_local_size(file.file_size, size, max_bytes),
         {:ok, source} <- open_local(path) do
      try do
        with {:ok, bytes} <- copy_local(source, io, max_bytes, 0),
             :ok <- verify_expected_size(file.file_size || size, bytes) do
          {:ok, bytes}
        end
      after
        File.close(source)
      end
    end
  end

  defp transfer(client, file, {:remote, path}, io, max_bytes, receive_timeout) do
    request = %HTTPDownloadRequest{
      url: Nadia.API.build_file_url(client, path),
      sink: &write_chunk(io, &1, max_bytes),
      max_bytes: max_bytes,
      expected_bytes: file.file_size,
      options: download_options(client, receive_timeout)
    }

    with {:ok, %HTTPDownloadResponse{} = response} <-
           HTTPClient.download(client.http_client, request),
         :ok <- verify_http_status(response.status_code),
         {:ok, actual} <- current_position(io),
         :ok <- verify_adapter_count(response.bytes_written, actual),
         :ok <- verify_expected_size(file.file_size, actual),
         :ok <- verify_content_length(response.headers, actual, max_bytes) do
      {:ok, actual}
    else
      {:error, reason} -> {:error, sanitize_adapter_error(reason)}
    end
  end

  defp stat_regular(path) do
    case File.stat(path) do
      {:ok, %File.Stat{type: :regular} = stat} -> {:ok, stat}
      {:ok, %File.Stat{}} -> {:error, :local_file_not_regular}
      {:error, reason} -> {:error, {:filesystem, :local_source, reason}}
    end
  end

  defp preflight_local_size(expected, actual, max_bytes) do
    cond do
      actual > max_bytes -> {:error, {:file_too_large, actual, max_bytes}}
      is_integer(expected) and expected != actual -> {:error, {:size_mismatch, expected, actual}}
      true -> :ok
    end
  end

  defp open_local(path) do
    case File.open(path, [:read, :binary]) do
      {:ok, io} -> {:ok, io}
      {:error, reason} -> {:error, {:filesystem, :local_source, reason}}
    end
  end

  defp copy_local(source, destination, max_bytes, count) do
    case :file.read(source, @chunk_size) do
      {:ok, chunk} ->
        with :ok <- write_chunk_at(destination, chunk, max_bytes, count) do
          copy_local(source, destination, max_bytes, count + byte_size(chunk))
        end

      :eof ->
        {:ok, count}

      {:error, reason} ->
        {:error, {:filesystem, :read, reason}}
    end
  end

  defp write_chunk(io, chunk, max_bytes) do
    with {:ok, count} <- current_position(io),
         :ok <- write_chunk_at(io, chunk, max_bytes, count) do
      :ok
    end
  end

  defp write_chunk_at(io, chunk, max_bytes, count) do
    with {:ok, size} <- iodata_length(chunk),
         next = count + size,
         true <- next <= max_bytes || {:error, {:too_large, next, max_bytes}},
         :ok <- write(io, chunk) do
      :ok
    end
  end

  defp iodata_length(chunk) do
    {:ok, IO.iodata_length(chunk)}
  rescue
    _error -> {:error, :invalid_chunk}
  end

  defp write(io, chunk) do
    case :file.write(io, chunk) do
      :ok -> :ok
      {:error, reason} -> {:error, {:filesystem, :write, reason}}
    end
  end

  defp current_position(io) do
    case :file.position(io, :cur) do
      {:ok, position} -> {:ok, position}
      {:error, reason} -> {:error, {:filesystem, :position, reason}}
    end
  end

  defp sync(io) do
    case :file.sync(io) do
      :ok -> :ok
      {:error, reason} -> {:error, {:filesystem, :sync, reason}}
    end
  end

  defp verify_temp_size(path, bytes, max_bytes) do
    case File.stat(path) do
      {:ok, %File.Stat{type: :regular, size: ^bytes}} when bytes <= max_bytes -> :ok
      {:ok, %File.Stat{size: size}} -> {:error, {:size_mismatch, bytes, size}}
      {:error, reason} -> {:error, {:filesystem, :stat_temp, reason}}
    end
  end

  defp verify_adapter_count(count, actual) when count == actual, do: :ok
  defp verify_adapter_count(count, actual), do: {:error, {:size_mismatch, count, actual}}

  defp verify_http_status(status) when status in [301, 302, 303, 307, 308],
    do: {:error, :redirect_not_allowed}

  defp verify_http_status(200), do: :ok
  defp verify_http_status(status) when is_integer(status), do: {:error, {:http_status, status}}
  defp verify_http_status(_status), do: {:error, :transport_error}

  defp verify_expected_size(nil, _actual), do: :ok
  defp verify_expected_size(expected, expected), do: :ok
  defp verify_expected_size(expected, actual), do: {:error, {:size_mismatch, expected, actual}}

  defp verify_content_length(headers, actual, max_bytes) do
    case content_length(headers) do
      :missing -> :ok
      {:ok, length} when length > max_bytes -> {:error, {:too_large, length, max_bytes}}
      {:ok, ^actual} -> :ok
      {:ok, length} -> {:error, {:size_mismatch, length, actual}}
      :invalid -> {:error, :invalid_content_length}
    end
  end

  defp content_length(headers) do
    values =
      for {key, value} <- headers,
          String.downcase(to_string(key)) == "content-length",
          do: value

    case values do
      [] -> :missing
      [value] -> parse_content_length(value)
      _values -> :invalid
    end
  end

  defp parse_content_length(value) do
    case Integer.parse(value) do
      {length, ""} when length >= 0 -> {:ok, length}
      _other -> :invalid
    end
  end

  defp download_options(client, receive_timeout) do
    timeout = receive_timeout || client.recv_timeout * 1000
    options = [recv_timeout: timeout]

    options =
      case client.proxy do
        proxy when is_binary(proxy) and byte_size(proxy) > 0 ->
          Keyword.put(options, :proxy, proxy)

        proxy when is_tuple(proxy) ->
          Keyword.put(options, :proxy, proxy)

        _other ->
          options
      end

    case client.proxy_auth do
      proxy_auth when is_tuple(proxy_auth) and tuple_size(proxy_auth) == 2 ->
        Keyword.put(options, :proxy_auth, proxy_auth)

      _other ->
        options
    end
  end

  defp publish(temp_path, destination, true) do
    case File.rename(temp_path, destination) do
      :ok -> {:ok, destination}
      {:error, reason} -> cleanup_error(temp_path, {:filesystem, :publish, reason})
    end
  end

  defp publish(temp_path, destination, false) do
    case File.ln(temp_path, destination) do
      :ok ->
        _ = File.rm(temp_path)
        {:ok, destination}

      {:error, :eexist} ->
        cleanup_error(temp_path, :destination_exists)

      {:error, _reason} ->
        cleanup_error(temp_path, :atomic_publication_unsupported)
    end
  end

  defp cleanup_error(temp_path, reason) do
    _ = File.rm(temp_path)
    {:error, reason}
  end

  defp sanitize_adapter_error(reason)
       when reason in [
              :unsupported_http_adapter,
              :redirect_not_allowed,
              :timeout,
              :closed,
              :econnrefused,
              :transport_error,
              :request_failed,
              :invalid_content_length,
              :invalid_sink_result,
              :invalid_chunk
            ],
       do: reason

  defp sanitize_adapter_error({:http_status, status}) when is_integer(status),
    do: {:http_status, status}

  defp sanitize_adapter_error({kind, first, second})
       when kind in [:too_large, :size_mismatch] and is_integer(first) and is_integer(second),
       do: {kind, first, second}

  defp sanitize_adapter_error({:filesystem, operation, reason})
       when is_atom(operation) and is_atom(reason),
       do: {:filesystem, operation, reason}

  defp sanitize_adapter_error(_reason), do: :transport_error
end
