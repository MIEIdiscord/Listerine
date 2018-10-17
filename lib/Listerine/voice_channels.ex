defmodule Listerine.VoiceChannels do

  def normalize_voice_channels(guild_id) do
    Guild.get(guild_id).channels
    |> Enum.filter(fn x -> x.type == 2 end)
    |> Enum.filter(fn x -> String.contains(x.name, "Study") end)
    |> Enum.filter(fn x -> length(Channel.get_voice_members(x)) < 1 end)
    |> Enum.sort(&(&1.position <= &2.position))
    |> fn [h | t] -> t end
    |> Enum.foreach()
  end
end
