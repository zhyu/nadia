defmodule Nadia.Client do
    use Tesla
    adapter Tesla.Adapter.Hackney, ssl_options: [{:versions, [:'tlsv1.2']}]
end