require 'discordrb'
require 'pry'
require 'configatron'
require_relative 'config/config.rb'

bot = Discordrb::Commands::CommandBot.new token: configatron.token, prefix: "!"

def is_pm?(event)
    event.channel.pm? == true
end

def needs_role?(role, user)
    user.role?(role) == false
end

def role_exists?(role)
    role != nil
end

def generate_group_role(group_type, group_name, event)
    name = group_name.downcase

    if group_type != "private"
        name += "[G]"
    end

    event.server.create_role(
        name: name,
        permissions: [])
end

def generate_group_permissions(role)
    allow = Discordrb::Permissions.new
    deny = Discordrb::Permissions.new
    allow.can_read_messages = true

    Discordrb::Overwrite.new(role, allow: allow, deny: deny)    
end

def generate_private_channel_permissions(event)
    allow = Discordrb::Permissions.new
    deny = Discordrb::Permissions.new
    deny.can_read_messages = true

    role = event.server.roles.find { |r| r.name.downcase == '@everyone'.downcase }

    Discordrb::Overwrite.new(role, allow: allow, deny: deny)
end

bot.command :register, description: "!register <server name> - Promotes a user to the 'Member' role on a server." do |event, *server_name|
    server = bot.servers.find { |id, data| data.name.downcase == server_name.join(" ").downcase }[1]
    user_on_server = server.users.find { |user| user.id == event.user.id }
    member_role = server.roles.find { |role| role.name.downcase == 'Member'.downcase }
    
    if role_exists?(member_role) && needs_role?(member_role, user_on_server)
        user_on_server.add_role(member_role)
        result_text = "You have been given **Member** privileges on #{server.name}!"
    else
        result_text = "You already have Member privileges on #{server.name}!"
    end

    "Welcome, #{event.user.name}! #{result_text}"
end

bot.command :join, description: "!join <group name> - Joins a private group." do |event, *group_name|
    if event.channel.name.downcase == "meepos-madhouse".downcase
        group_role = event.server.roles.find { |role| role.name.downcase == group_name.join("-").downcase }
        
        if role_exists?(group_role)
            if needs_role?(group_role, event.user)
                event.user.add_role(group_role)
                result_text = "You have been added to the **#{group_role.name}** group!"
            else
                result_text = "You already belong to that group!"
            end
        else
            result_text = "That group does not exist :( Why not create it? (Try !create #{group_name.join(" ")})"
        end

        result_text
    else
        event.message.delete
    end
end

bot.command :leave, description: "!leave <group name> - Leaves a private group." do |event, *group_name|
    if event.channel.name.downcase == "meepos-madhouse".downcase
        group_role = event.server.roles.find { |role| role.name.downcase == group_name.join("-").downcase }
        
        if role_exists?(group_role)
            if needs_role?(group_role, event.user)
                result_text = "You aren't a member of that group!"
            else
                event.user.remove_role(group_role)
                result_text = "You have been removed from the **#{group_role.name}** group!"
            end
        else
            result_text = "That group does not exist :("
        end

        result_text
    else
        event.message.delete
    end
end

bot.command :create, description: "!create <group type (public|private)> <group name> - Creates a public or private group and joins the user to it." do |event, group_type, group_name|
    if event.channel.name == "meepos-madhouse"
        name = group_name
        role = event.server.roles.find { |role| role.name.downcase == name.downcase }
    
        if role_exists?(role)
            result_text = "It appears that someone has already tried to create this group."\
            "Ask a Mod if you think this is an error"
        else
            new_role = generate_group_role(group_type.downcase, name, event)
            
            group_overwrite = generate_group_permissions(new_role)
            private_overwrite = generate_private_channel_permissions(event)
        
            new_channel = event.server.create_channel(
                name.downcase, 
                0,
                permission_overwrites: [private_overwrite, group_overwrite])

            new_voice_channel = event.server.create_channel(
                name.downcase, 
                2,
                permission_overwrites: [private_overwrite, group_overwrite])
            
            event.user.add_role(new_role)
    
            result_text = "You have created the #{name} group! Have your friends type"\
            "`!join #{name}` to join."

            if !new_role.name.include?("[G]")
                event.message.delete
                event.user.pm(result_text)
                result_text = nil
            end
        end
    
        result_text
    else
        event.message.delete
    end
end

bot.command :delete, description: "!delete <group name> - Deletes a private group (requires Moderator rank)." do |event, group_name|
    if event.channel.name == "meepos-madhouse"
        name = group_name.downcase

        role = event.server.roles.find do |role| 
            target_name = name
            if role.name.include?("[G]")
                target_name += "[G]"
            end

            role.name.downcase == target_name.downcase
        end

        moderator_role = event.server.roles.find { |role| role.name.downcase == "Moderator".downcase }
        
        if !event.user.roles.include?(moderator_role)
            result_text = "You are not a member of the Moderator role!"
        elsif role_exists?(role) && event.user.roles.include?(moderator_role)
            channels = event.server.channels.find_all { |channel| channel.name.downcase == name.downcase }
            channels.each { |channel| channel.delete }
            role.delete
            result_text = "Successfully deleted the #{group_name} group!"
        else 
            result_text = "That group does not exist!"
        end
        
        result_text
    else
        event.message.delete
    end
end

bot.command :list, description: "!list - Lists all created groups." do |event|
    roles = event.server.roles.find_all {|role| role.name.include?("[G]") }
    role_names = roles.map { |role| "* " + role.name.split("[")[0].upcase }

    if role_names.length == 0
        result_text = "No groups exist! (create one with `!create <group_name>`)" 
    else 
        result_text = "```\nCurrent Groups:\n" + role_names.join("\n") + "```"
    end
end


bot.command :prune do |event, n|
    event.channel.prune(n.to_i)
    "Pruned!"
end

bot.run