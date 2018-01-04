require 'discordrb'
require 'pry'
require 'configatron'

require_relative 'config/config.rb'
require_relative 'helpers.rb'
require_relative 'containers/group_manager.rb'

include GroupManager

bot = Discordrb::Commands::CommandBot.new token: configatron.token, prefix: configatron.command_prefix

bot.command :register, description: configatron.register_help do |event, *server_name|
    server = bot.servers.find { |id, data| data.name.downcase == server_name.join(" ").downcase }[1]
    user_on_server = server.users.find { |user| user.id == event.user.id }
    member_role = server.roles.find { |role| role.name.downcase == configatron.member_role_name.downcase }
    
    if role_exists?(member_role) && needs_role?(member_role, user_on_server)
        user_on_server.add_role(member_role)
        result_text =  configatron.given_member_privileges
    else
        result_text = configatron.already_have_member_privileges
    end

    result_text
end

bot.command :prune do |event, n|
    event.channel.prune(n.to_i)
    configatron.pruned
end

bot.include! GroupManager
bot.run