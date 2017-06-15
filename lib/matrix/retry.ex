defmodule Matrix.Retry do

  defmacro retry_post(url: url, body: body, headers: headers) do
    quote do
      retry delay: 500, count: 1 do
        case HTTPoison.post(unquote(url), unquote(body), unquote(headers)) do
          {:ok, %HTTPoison.Response{status_code: 200}} ->
            true

          _ ->
            Logger.warn "[RETRY] POST #{unquote(url)}"
            false
        end
      after
        {:ok, ""}
      else
        {:error, :handshake_failed}
      end
    end
  end

  defmacro retry([delay: delay, count: count], do: do_clause, after: after_clause, else: else_clause) do
    quote do
      0..(unquote(count))
      |> Enum.map(&(&1 * unquote(delay)))
      |> Enum.reduce_while(nil, fn (delay, _acc) ->
        :timer.sleep(delay)

        case unquote(do_clause) do
          false  -> {:cont, false}
          nil    -> {:cont, nil}
          result -> {:halt, result}
        end
      end)
      |> case do
        false -> unquote(else_clause)
        nil   -> unquote(else_clause)
        _     -> unquote(after_clause)
      end
    end
  end

end
