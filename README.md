# uVNC Remote Control
Frontend for uVNC, like (Gen/Zen)Control created with PureBASIC (https://www.purebasic.com/)

Application:

  - Little tool to connect to a remote machine on a domain network
  - Typical use: Trying to assist a user remotely
  
  -----------------------
-Concept (normal mode)-
-----------------------

This is the normal behavior:

  1 check if there's a valid IP address assigned to the client
  2 ping the client
  3 map the client C$, create the RCTemp folder and copy VNC over
  4 start the vnc server on the remote client
  5 start vnc viewer on localhost and connect to client
  6 after viewer exits, stop VNC service, delete files on client
  7 unhide GUI on localhost

Example setup
-------------

Assume the following setup:

  - a user is at their desk at another location, connected to the network
  - this user is having an issue with an application
  - we try to assist remotely by using this tool

Notes
-----

You MUST specify client IP or name and a description

VNCRemoteControl is FOR DOMAIN NETWORK USE only. It doesn't work across the internet.

To perform a Remote Control of a machine, the following requirements must be met:

•The machine initiating the session and the target must be running Windows 2000 or higher.

•The machine initiating the session and the target must be in trusted domains.

•The user running the Remote Control executable or clicking the Remote Control action must have administrative privileges on the target machine.

•TCP ports 139, 445 and 5900 must be open on the target machine.

•The Server service, found in Windows Services, must be started on the target machine.

•The administrative shares C$ and ADMIN$ must be accessible on the target machine.


2016-2020 uVNC Remote Control, NO RIGHTS RESERVED

Do whatever you like with this program. But remember: I / we do not accept any 
responsibility for any damage caused by (the use of) this software, either direct
or indirect. Use it at your own risk.

THE USE OF THIS PROGRAM IS ENTIRELY AT YOUR OWN RISK. Yes. You are allowed to use
it :-)

uVNC Remote Control is written in PureBasic (c) Fantaisie Software. uVNCRemoteControl is in
no way affiliated with PureBasic or Fantaisie Software, nor do we claim any rights
to their products. (You should try PureBasic though, it's a great language!)

If uVNCRemoteControl or PureBasic uses any other licensed components, you should abide
those licenses as well.


*** REGISTRATION ***

There is no need to register.


*** SUPPORT ***

uVNC Remote Control is FREE by design.


*** CONTACT ***

Send an email to oldnesjunkie@gmail.com, but even better: visit the PureBasic forum!
