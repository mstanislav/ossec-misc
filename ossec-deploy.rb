#!/usr/bin/env ruby

require 'rubygems'
require 'time'

@agent_conf = '/var/ossec/etc/shared/agent.conf'
@control_bin = '/var/ossec/bin/agent_control'
@server_hash = `md5sum /var/ossec/etc/shared/agent.conf`.split('  ').fetch(0).strip
@agents = Hash.new

def restart_server
  print "\nRestarting OSSEC Server Instance... "
  system('service ossec-hids restart &>/dev/null')
  print "Done!\n"
end

def get_last_update(agent_id)
  output = `#{@control_bin} -i #{agent_id}`
  if output == '' or output == nil
    return false
  else
    return output.split('Last keep alive:     ').fetch(1).split("\n").fetch(0)
  end
end

def check_window(last_update)
  if (Time.now.to_i - Time.parse(last_update).to_i) < 55
    return true
  else
    return false
  end
end

def get_active_agents
  print "Retrieving active OSSEC agents..... "
  output = `#{@control_bin} -lc | grep 'ID:' | grep -v 'Local'`
  output.split('ID: ').each do |agent|
    if agent.strip != nil and agent.strip != ''
      parts = split_agent_parts(agent)
      @agents[parts['ID']] = parts
    end
  end
  print "Done!\n"
end

def split_agent_parts(string)
  id = string.split(',').fetch(0)
  name = string.split('Name: ').fetch(1).split(',').fetch(0)
  ip =  string.split('IP: ').fetch(1).split(',').fetch(0)
  return { 'ID' => id, 'Name' => name, 'IP' => ip, 'Restarted' => false, 'Hash' => nil }
end

def set_agent_hash(agent_id)
  output = `#{@control_bin} -i #{agent_id}`
  if output.split('Client version:      ').fetch(1).split(' / ').size > 0
    @agents[agent_id]['Hash'] = output.split('Client version:      ').fetch(1).split(' / ').fetch(1).split("\n").fetch(0).strip
  end
end

def restart_agent(agent_id)
  `#{@control_bin} -R #{agent_id}`
  @agents[agent_id]['Restarted'] = true
  return true
end

def restart_agents
  print "Restarting active OSSEC agents.....\n\n"
  $restarted = 0
  while (1)
   @agents.each do |id,values|
    set_agent_hash(id)
    if values['Restarted'] == false
      if check_window(get_last_update(id)) == false or values['Hash'] != @server_hash
        puts "Waiting for agent #{id} (#{values['Name']} - #{values['IP']})..."
      else
        puts "*** Restarting agent #{id} (#{values['Name']} - #{values['IP']}) ***"
        restart_agent(id)
        $restarted += 1
      end
    end
   end

   if @agents.size - $restarted > 0
     puts "Agents Left: #{@agents.size - $restarted} ; Agents Restarted: #{$restarted} -- Sleeping for 15 seconds.\n\n"
     sleep 15
   else
     puts "\nAll #{@agents.size} agent(s) have been restarted. Exiting.\n\n"
     break
   end
  end
end

restart_server
get_active_agents
restart_agents
