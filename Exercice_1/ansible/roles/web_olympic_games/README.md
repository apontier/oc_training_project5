Role Name
=========

Configure Olympic Games Starter Web App.

Role Variables
--------------

The vars used by this role are :
- web_olympic_games_app_user : the owner of the web app files (default : www-data)
- web_olympic_games_app_group : the group of the web app files (default : www-data)
- web_olympic_games_app_name : the name of the web app (default : olympic-games-starter)

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - role: web_olympic_games

License
-------

MIT
