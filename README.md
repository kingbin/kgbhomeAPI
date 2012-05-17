kgbhomeAPI
==========
Home Automation Sinatra RESTful API

I have dragged my feet on this idea for a while and have wondered the best approach of creating my own home automation system. There are a couple things I need to figure out and add to this project, but this is a simple start to another stab at the project I have dreamed up.

### Simple Installation

1. Clone the project
2. Create a config.yml file in the root with the following settings:

        thermostatIP: 192.168.x.x
        port: 9494  
 
3. Start the server by issuing rackup config.ru


### Contribute
I need to add a form of authentication for obvious reasons before adding other verbs to the api. I need to figure out how to add dynamic support for plugging in new modules to the project along with setting up in a passenger install.

chris blazek
