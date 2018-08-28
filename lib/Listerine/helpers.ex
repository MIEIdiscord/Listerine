defmodule Listerine.Helpers do
  use Coxir

  def add_role_list(message, role_names) do
    guild = message.channel.guild_id
    roles = Guild.get_roles(guild)

    if role_names != [] do
      [head | tail] = role_names
      add_role_name(head, message, roles, guild)
      add_role_list(message, tail)
    end
  end

  def add_role_name(_name, message, [], _guild) do
    Message.reply(message, "Role does not exist")
  end

  def add_role_name(name, message, [head | tail], guild) do
    member = Guild.get_member(guild, message.author.id)

    if head.name == name do
      Member.add_role(member, head.id)
    else
      add_role_name(name, message, tail, guild)
    end
  end

  def intersect(a, b), do: a -- a -- b
end
