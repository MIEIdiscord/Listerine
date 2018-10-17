defmodule Listerine.VoiceChannels do
  use Coxir

  def normalize_voice_channels(guild_id) do
    Guild.get(guild_id).channels
    |> Enum.filter(fn x -> x.type == 2 end)
    |> Enum.filter(fn x -> String.contains?(x.name, "Study") end)
    |> Enum.filter(fn x -> length(Channel.get_voice_members(x)) < 1 end)
    |> (fn l ->
          cond do
            length(l) > 1 -> delete_unnecessary_channels(l)
            length(l) < 1 -> create_new_channels(guild_id)
            true -> nil
          end
        end).()
  end

  defp delete_unnecessary_channels(channels) do
    channels
    |> Enum.sort(&(&1.position <= &2.position))
    |> (fn [_h | t] -> t end).()
    |> Enum.each(&Channel.delete(&1))
  end

  defp create_new_channels(guild_id) do
    IO.puts("before: #{length(Guild.get(guild_id).channels)}")
    Guild.create_channel(Guild.get(guild_id), %{name: "Study", type: 2})
    IO.puts("after: #{length(Guild.get(guild_id).channels)}")
  end
end
