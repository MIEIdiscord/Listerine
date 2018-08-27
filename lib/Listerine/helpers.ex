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

  def add_role_name(name, message, roles, guild) do 
    member = Guild.get_member(guild, message.author.id)
    if roles != [] do 
      [head | tail] = roles
      if head.name == name do 
        Member.add_role(member, head.id)
      else
        add_role_name(name, message, tail, guild)
      end
    else 
      Message.reply(message, "Role does not exist")
    end
  end 
end 
