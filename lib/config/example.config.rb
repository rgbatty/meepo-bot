## Installation

configatron.token = 'YOUR_TOKEN'
configatron.command_prefix = 'YOUR_PREFIX'
configatron.command_channel = "YOUR_COMMAND_CHANNEL"
configatron.member_role_name = "YOUR_MEMBER_ROLE"
configatron.everyone_role_name = 'YOUR_EVERYONE_ROLE'
configatron.private_group_flag = "YOUR_PRIVATE_GROUP_FLAG"
configatron.public_role_flag = '[G]'

## Help Text
configatron.register_help = "!register <server name> - Promotes a user to the 'Member' role on a server."
configatron.join_help = "!join <group name> - Joins a group."
configatron.leave_help = "!leave <group name> - Leaves a group."
configatron.create_help = "!create  <group name> [#{configatron.private_group_flag}] - Creates a group (optionally private) and joins the user to it."
configatron.delete_help = "!delete <group name> - Deletes a private group (requires Moderator rank)."
configatron.list_help = "!list - Lists all created groups."

## Flavor Text
configatron.given_member_privileges = "Welcome! You have been given **#{configatron.member_role_name}** privileges on the server!"
configatron.already_have_member_privileges = "Hey there! You already have **#{configatron.member_role_name}** privileges on the server!"
configatron.pruned = "Pruned!"
configatron.added_to_group = "You have been added to the group!"
configatron.already_in_group = "You already belong to that group!"
configatron.group_does_not_exist = "That group does not exist :( Why not create it?"
configatron.does_not_belong_to_group = "You aren't a member of that group!"
configatron.removed_from_group = "You have been removed from the group!"
configatron.group_already_exists = "It appears that someone has already tried to create this group. Ask a Mod if you think this is an error"
configatron.invalid_group_name = "Please make sure your group name only includes letters and hyphens."
configatron.group_created = "Group successfully created!"
configatron.group_deleted = "Group successfully deleted!"
configatron.not_a_mod = "You are not a member of the Moderator role!"
configatron.no_groups_exist = "No groups exist! (create one with `!create <group_name>`)"