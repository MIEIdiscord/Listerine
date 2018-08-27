defmodule Listerine.Channels do
  @moduledoc """
  This module provides functions to create and remove private channels
  """

  use Coxir

  # Decodes the config.json file
  defp get_courses() do
    case File.read("config.json") do
      {:ok, ""} -> nil
      {:ok, body} -> Poison.decode!(body)
      {:error, _error} -> nil
    end
  end

  @doc """
  Adds courses to the guild and registers them to the config.json file
  """
  def add_courses(guild, year, courses) do
    new_map =
      case get_courses() do
        nil ->
          %{"courses" => %{year => courses}}

        map ->
          case map["courses"][year] do
            nil -> put_in(map["courses"][year], Enum.uniq(courses))
            _ -> update_in(map["courses"][year], fn cl -> Enum.uniq(cl ++ courses) end)
          end
      end

    # TODO: Avoid repeats
    create_course_channels(guild, courses)
    File.write("config.json", Poison.encode!(new_map), [:binary])
  end

  # Creates the private channels, corresponding roles and sets the permissions
  defp create_course_channels(_, []), do: nil

  defp create_course_channels(guild, [course | others]) do
    role =
      Guild.create_role(
        guild,
        %{:name => course, :hoist => false, :mentionable => true}
      )

    ow = [
      %{id: get_role(Guild.get_roles(guild), "@everyone").id, type: "role", deny: 1024},
      %{id: role.id, type: "role", allow: 1024}
    ]

    cat = Guild.create_channel(guild, %{name: course, type: 4, permission_overwrites: ow})
    Guild.create_channel(guild, %{name: "duvidas", type: 0, parent_id: cat.id})

    create_course_channels(guild, others)
  end

  # Returns a role with a given name or `nil` if none are found
  defp get_role(l, name), do: Enum.find(l, fn e -> e[:name] == name end)

  @doc """
  Removes courses from the config.json file and the corresponding channels and roles
  from the guild.
  """
  def remove_courses(guild, year, courses) do
    new_map =
      case get_courses() do
        nil ->
          %{"courses" => %{}}

        map ->
          update_in(map["courses"][year], fn cl -> Enum.uniq(cl -- courses) end)
      end

    # TODO: Only let registered channels be deleted
    remove_course_channels(guild.channels, courses)
    File.write("config.json", Poison.encode!(new_map), [:binary])
  end

  # Removes the channels and roles from the guild
  defp remove_course_channels(_, []), do: nil

  defp remove_course_channels(channels, [course | others]) do
    case Enum.find(channels, fn ch -> ch.name == course end) do
      nil ->
        nil

      ch ->
        sub_channels = Enum.filter(channels, fn sc -> sc[:parent_id] == ch.id end)
        Enum.each(sub_channels, fn sc -> Channel.delete(sc) end)
        Role.delete(get_role(Guild.get_roles(Guild.get(ch.guild_id)), course))
        Channel.delete(ch)
    end

    remove_course_channels(channels, others)
  end
end
