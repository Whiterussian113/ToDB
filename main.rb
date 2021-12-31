require 'discordrb'
require 'set'
bot_token = 'OTIwODYyMTkzMzMzOTY0ODIw.Ybqhvw.u3-el_Yw0563ronoRH_y-F92SZI'
bot = Discordrb::Bot.new token: bot_token
p_list_name = "kb_players.txt"
unless File.exists?(p_list_name)
  File.write(p_list_name,"")
end
d_list_name = "kb_darer.txt"
unless File.exists?(d_list_name)
  File.write(d_list_name,"")
end
v_list_name = "kb_victim.txt"
unless File.exists?(v_list_name)
  File.write(v_list_name,"")
end
player_list = File.read(p_list_name).split.map(&:to_i).to_set
active = File.read(d_list_name).split.map(&:to_i).to_set
victim = File.read(v_list_name).split.map(&:to_i).to_set

bot.message(with_text: '~register') do |event|
  runner = event.user.id
  if player_list.to_s.include? runner.to_s
    event.respond "You are already a player <@#{runner}>"
  else
    event.respond "Welcome to the game <@#{runner}>"
    player_list.add(runner)
    File.write(p_list_name, player_list.to_a.join("\n"))
  end
end

bot.message(with_text: '~deregister') do |event|
  runner = event.user.id
  puts bot.users[runner].name
  if player_list.to_s.include? runner.to_s
    event.respond "Thanks for playing <@#{runner}>"
    player_list.delete(runner)
    File.write(p_list_name, player_list.to_a.join("\n"))
  else
   event.respond "You are not currently a player <@#{runner}>"
  end
end

bot.message(with_text: '~players') do |event|
  event.respond "Current Players:\n"
  player_list.each do |player|
    event.respond bot.users[player].username+"\n"
  end
end

bot.message(with_text: '~active') do |event|
  event.respond "Active Players:\n\
  #{bot.users[active.to_a[0]].username}- Asker\n\
  #{bot.users[victim.to_a[0]].username} - Victim\n"
end

bot.message(with_text: '~spin') do |event|
  runner = event.user.id
  run_set = [runner].to_set
  spin_set = player_list - run_set
  spin_set = spin_set.to_a
  asked = spin_set.sample
  event.respond "<@#{runner}> would like to know:\n\n<@#{asked}> Truth or Dare?"
  File.write(d_list_name, runner)
  File.write(v_list_name, asked)
  victim = [asked].to_set
  active = run_set
end

bot.message(with_text: '~respin') do |event|
  spin_set = player_list - (active + victim)
  spin_set = spin_set.to_a
  asked = spin_set.sample
  event.respond "<@#{active.to_a[0]}> would like to know:\n\n<@#{asked}> Truth or Dare?"
  File.write(v_list_name, asked)
  victim = [asked].to_set
end

bot.message(with_text: '~sync') do |event|
  player_list = File.read(p_list_name).split.map(&:to_i).to_set
  active = File.read(d_list_name).split.map(&:to_i).to_set
  victim = File.read(v_list_name).split.map(&:to_i).to_set
end

bot.message(with_text: '~push') do |event|
  File.write(p_list_name, player_list.to_a.join("\n"))
  File.write(d_list_name, active.to_a[0])
  File.write(v_list_name, victim.to_a[0])
end

bot.message(with_text: '~help') do |event|
  event.respond "Commands for the bot:\n\
  ~register : Adds you to the game\n\
  ~deregister : Removes you from the game\n\
  ~players : List active players\n\
  ~spin : Randomly select a player to be Truthed or Dared\n\
  ~respin : Reselect a victim\n\
  ~active : Get Active Players"
end
bot.run