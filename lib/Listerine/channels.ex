defmodule Listerine.Channels do
  @moduledoc """
  This module provides functions to create and remove private channels
  """

  use Coxir

  # Decodes the config.json file
  defp get_courses() do
    case File.read("config.json") do
      {:ok, ""} -> nil
      {:ok, body} -> Poison.decode!(body)["courses"]
      _ -> nil
    end
  end

  defp save_courses(courses) do
    new_map =
      case File.read("config.json") do
        {:ok, ""} ->
          %{"courses" => courses}

        {:ok, body} ->
          map = Poison.decode!(body)
          Map.put(map, "courses", courses)

        _ ->
          %{"courses" => courses}
      end

    File.write("config.json", Poison.encode!(new_map), [:binary])
  end

  @doc """
  Adds courses to the guild and registers them to the config.json file
  """
  def add_courses(guild, year, courses) do
    courses = Enum.uniq(courses)

    {courses, new_map} =
      case get_courses() do
        nil ->
          {courses, %{year => courses}}

        map ->
          case map[year] do
            nil ->
              {courses, put_in(map[year], courses)}

            crs ->
              # Don't allow repeats
              courses = courses -- crs
              {courses, update_in(map[year], fn cl -> cl ++ courses end)}
          end
      end

    added = create_course_channels(guild, courses)

    if length(added) > 0 do
      save_courses(new_map)
    end

    added
  end

  # Creates the private channels, corresponding roles and sets the permissions
  defp create_course_channels(_, []), do: []

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

    [cat.name | create_course_channels(guild, others)]
  end

  # Returns a role with a given name or `nil` if none are found.
  defp get_role(l, name), do: Enum.find(l, fn e -> e[:name] == name end)

  @doc """
  Removes courses from the config.json file and the corresponding channels and roles
  from the guild.

  Returns the list of removed channels or `nil` if none where removed.
  """
  def remove_courses(guild, courses) do
    case get_courses() do
      nil ->
        nil

      map ->
        # Only let registered channels be deleted
        courses =
          map
          |> Map.values()
          |> List.flatten()
          |> Listerine.Helpers.intersect(courses)

        new_map =
          Enum.reduce(Map.keys(map), map, fn x, map ->
            update_in(map[x], fn cl -> cl -- courses end)
          end)

        removed = remove_course_channels(guild.channels, courses)

        if length(removed) > 0 do
          save_courses(new_map)
        end

        removed
    end
  end

  # Removes the channels and roles from the guild
  defp remove_course_channels(_, []), do: []

  defp remove_course_channels(channels, [course | others]) do
    ch =
      case Enum.find(channels, fn ch -> ch !== nil && ch.name == course end) do
        nil ->
          nil

        ch ->
          sub_channels = Enum.filter(channels, fn sc -> sc[:parent_id] == ch.id end)
          Enum.each(sub_channels, fn sc -> Channel.delete(sc) end)
          Role.delete(get_role(Guild.get_roles(Guild.get(ch.guild_id)), course))
          Channel.delete(ch)
      end

    case ch do
      nil -> remove_course_channels(channels, others)
      _ -> [ch.name | remove_course_channels(channels, others)]
    end
  end
end
