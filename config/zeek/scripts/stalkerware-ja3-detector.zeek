# Load the list of JA3 hashes from stalkerware-ja3.zeek
# One JA3 hash per line in that file
redef JA3::hash_list = set();

event zeek_init()
    {
    local path = fmt("%s/stalkerware-ja3.zeek", getenv("ZEEK_SCRIPT_DIR"));
    if ( path != "" )
        {
        local file = open(path);
        if ( file != nil )
            {
            local line: string;
            while ( (line = read_file_line(file)) != "" )
                {
                line = strip(line);
                if ( line != "" )
                    add JA3::hash_list[line];
                }
            close(file);
            }
        }
    }

# This event fires whenever Zeek sees a TLS handshake
event tls_client_hello(c: connection)
    {
    if ( c?$ssl )
        {
        local ja3 = c$ssl$ja3;
        if ( ja3 in JA3::hash_list )
            {
            print fmt("ALERT: JA3 match for suspected stalkerware C2: %s (conn %s)",
                      ja3, c$id);
            }
        }
    }
