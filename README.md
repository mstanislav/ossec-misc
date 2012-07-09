ossec-misc
==========
This repository is to hold scripts and other files that I've built which has helped me deploy OSSEC. The files are to be treated as-is but likely are here because of success from my own usage. Your mileage may vary.

ossec-deploy.rb
---------------
**Background:** This script was built to solve a problem that I have when utilizing OSSEC Windows agents. The Windows Firewall will kill UDP connections which are established, but idle, after 60 seconds. Because of this, making things such as active response work properly is quite a challenge. Further, once you save a new configuration file, it can be a bit of a challenge to ensure it gets pushed-out and that active response or manual agent\_control actions restarts each agent. Even if you aren't using Windows agents, this script could potentially make your life much easier.

**Functionality:** When this script is called, it will do various things:
* Restart your OSSEC server so that the configuration file you have saved will get pushed out more quickly
* Gather all ACTIVE (and non-local) agents that are currently configured for your deployment
* Loop through every agent, ensuring that the shared agent configuration hash matches the server's version and that the agent has connected within 55 seconds
* Restart each agent that matches the above criteria and mark the agent as 'restarted'

**Example Output**
<pre>[root@test ~]# ./ossec-deploy.rb 

Restarting OSSEC Server Instance... Done!
Retrieving active OSSEC agents..... Done!
Restarting active OSSEC agents.....

Waiting for agent 002 (server-1 - 10.1.1.207)...
Waiting for agent 003 (server-2 - 10.1.2.89)...
Agents Left: 2 ; Agents Restarted: 0 -- Sleeping for 15 seconds.

Waiting for agent 002 (server-1 - 10.1.1.207)...
Waiting for agent 003 (server-2 - 10.1.2.89)...
Agents Left: 2 ; Agents Restarted: 0 -- Sleeping for 15 seconds.

*** Restarting agent 002 (server-1 - 10.1.1.207) ***
Waiting for agent 003 (server-2 - 10.1.2.89)...
Agents Left: 1 ; Agents Restarted: 1 -- Sleeping for 15 seconds.

Waiting for agent 003 (server-2 - 10.1.2.89)...
Agents Left: 1 ; Agents Restarted: 1 -- Sleeping for 15 seconds.

Waiting for agent 003 (server-2 - 10.1.2.89)...
Agents Left: 1 ; Agents Restarted: 1 -- Sleeping for 15 seconds.

*** Restarting agent 003 (server-2 - 10.1.2.89) ***

All 2 agent(s) have been restarted. Exiting.</pre>
