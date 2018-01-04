def is_pm?(event)
    event.channel.pm? == true
end

def needs_role?(role, user)
    user.role?(role) == false
end

def role_exists?(role)
    role != nil
end

def public_group?(group_type)
    group_type == nil || (group_type.downcase != configatron.private_group_flag)
end

def find_everyone_role(event)
    event.server.roles.find { |r| r.name.downcase == configatron.everyone_role_name.downcase }
end

def find_group_role(event, group_name)
    event.server.roles.find do |role| 
        target_name = role.name

        if role.name.include?(configatron.public_role_flag)
            target_name = target_name.split(configatron.public_role_flag.chars[0])[0]
        end

        target_name.downcase == group_name.downcase
    end
end

def generate_group_role(group_type, group_name, event)
    name = group_name.downcase

    if public_group?(group_type)
        name += configatron.public_role_flag
    end
    
    event.server.create_role(name: name, permissions: [])
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

    role = find_everyone_role(event)

    Discordrb::Overwrite.new(role, allow: allow, deny: deny)
end

def invalid_name?(name)
    special = "?<>',?[]}{=)(*&^%$#`~{}_"
    regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/ 
    name =~ regex
end

def in_command_channel?(event)
    event.channel.name.downcase == configatron.command_channel.downcase
end