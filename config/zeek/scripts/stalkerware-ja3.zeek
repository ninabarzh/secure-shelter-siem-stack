event ssl_client_hello(c: connection, version: count, possible_ts: time, cipher_suites: index_vec, comp_methods: index_vec, exts: index_vec)
{
    local ja3 = fmt("%s,%s,%s", version, cipher_suites, exts);
    if ( /769,|771,/ in ja3 && /1234567890abcdef1234567890abcdef/ in ja3 )
        print fmt("Possible stalkerware JA3 fingerprint on %s", c$id$orig_h);
}
