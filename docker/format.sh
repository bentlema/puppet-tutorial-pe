# .ID          Container ID
# .Image       Image ID
# .Command     Quoted command
# .CreatedAt   Time when the container was created.
# .RunningFor  Elapsed time since the container was started.
# .Ports       Exposed ports.
# .Status      Container status.
# .Size        Container disk size.
# .Names       Container names.
# .Labels      All labels assigned to the container.
# .Label       Value of a specific label for this container. For example '{{.Label "com.docker.swarm.cpu"}}'
# .Mounts      Names of the volumes mounted in this container.

FORMAT="
Container ID: {{.ID}}
     Names: {{.Names}}
    Status: {{.Status}}
     Image: {{.Image}}
   Command: {{.Command}}
     Ports: {{.Ports}}
"

alias dps="docker ps -a --format \"$FORMAT\""
