# Welcome to the Mojo-Dojo

Some fun code stuff around the new AI Programming language Mojo!  
It is free to use, but you need to sign up for a key.

## How to use:
1. Build Docker container with `docker build --build-arg AUTH_KEY=<you mojo key> -t mojo .`
2. Run container with `docker run -it -v ${PWD}/code:/code mojo bash`
3. Attach VS code to container
4. Happy Hacking