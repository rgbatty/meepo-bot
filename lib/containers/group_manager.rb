module GroupManager
    extend Discordrb::Commands::CommandContainer

    def create_group(event, group_type, group_name)
        new_role = generate_group_role(group_type, group_name, event)
                
        group_overwrite = generate_group_permissions(new_role)
        private_overwrite = generate_private_channel_permissions(event)
    
        new_channel = event.server.create_channel(
            group_name.downcase, 
            0,
            permission_overwrites: [private_overwrite, group_overwrite])

        new_voice_channel = event.server.create_channel(
            group_name.downcase, 
            2,
            permission_overwrites: [private_overwrite, group_overwrite])
        
        new_role
    end

    def group_deletable?(event, group_role, moderator_role)
        role_exists?(group_role) && event.user.roles.include?(moderator_role)
    end

    def resolve_private_group_result_text(event, role, result_text)
        if !role.name.include?(configatron.public_role_flag)
            event.message.delete
            event.user.pm(result_text)
            result_text = nil
        end

        result_text
    end

    command :join, description: configatron.join_help do |event, group_name|
        if in_command_channel?(event)
            group_role = find_group_role(event, group_name)
            
            if role_exists?(group_role)
                if needs_role?(group_role, event.user)
                    event.user.add_role(group_role)
                    result_text = configatron.added_to_group
                else
                    result_text = configatron.already_in_group
                end
            else
                result_text = configatron.group_does_not_exist
            end
    
            result_text
        else
            event.message.delete
        end
    end
    
    command :leave, description: configatron.leave_help do |event, group_name|
        if in_command_channel?(event)
            group_role = find_group_role(event, group_name)
            
            if role_exists?(group_role)
                if needs_role?(group_role, event.user)
                    result_text = configatron.does_not_belong_to_group
                else
                    event.user.remove_role(group_role)
                    result_text = configatron.removed_from_group
                end
            else
                result_text = configatron.does_not_belong_to_group
            end
    
            result_text
        else
            event.message.delete
        end
    end
    
    command :create, description: configatron.create_help  do |event, group_name, group_type|
        if in_command_channel?(event)
            role = event.server.roles.find do |role| 
                role.name.downcase == group_name.downcase || (role.name.downcase == (group_name + configatron.public_role_flag).downcase)
            end
        
            if role_exists?(role)
                result_text = configatron.group_already_exists
            elsif invalid_name?(group_name)
                result_text = configatron.invalid_group_name
            else
                new_role = create_group(event, group_type, group_name)
                event.user.add_role(new_role)
        
                result_text = resolve_private_group_result_text(event, new_role, configatron.group_created )
            end
        
            result_text
        else
            event.message.delete
        end
    end
    
    command :delete, description: configatron.delete_help do |event, group_name|
        if in_command_channel?(event)
            group_role = find_group_role(event, group_name)
            moderator_role = event.server.roles.find { |role| role.name.downcase == "Moderator".downcase }
            
            if !event.user.roles.include?(moderator_role)
                result_text = configatron.not_a_mod
            elsif group_deletable?(event, group_role, moderator_role)
                channels = event.server.channels.find_all { |channel| channel.name.downcase == group_name.downcase }
                channels.each { |channel| channel.delete }
                group_role.delete

                result_text = resolve_private_group_result_text(event, group_role, configatron.group_deleted)
            else 
                result_text = configatron.group_does_not_exist
            end
            
            result_text
        else
            event.message.delete
        end
    end
    
    command :list, description: configatron.list_help do |event|
        roles = event.server.roles.find_all {|role| role.name.include?(configatron.public_role_flag) }
        role_names = roles.map { |role| "* " + role.name.split(configatron.public_role_flag.chars[0])[0].upcase }.uniq
    
        if role_names.length == 0
            result_text =  configatron.no_groups_exist
        else 
            result_text = "```\nCurrent Groups:\n" + role_names.join("\n") + "```"
        end
    end
end