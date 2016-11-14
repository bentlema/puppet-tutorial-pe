
Here's the output from the inital puppet run on the **agent** VM...

```
[root@agent ~]# puppet agent -t
Info: Caching certificate for agent.example.com
Info: Caching certificate_revocation_list for ca
Info: Caching certificate for agent.example.com
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/aio_agent_build.rb]/ensure: defined content as '{md5}cdcc1ff07bc245c66cc1d46be56b3af5'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/aio_agent_version.rb]/ensure: defined content as '{md5}d05c8cbf788f47d33efd46a935dda61e'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/pe_build.rb]/ensure: defined content as '{md5}ee54c728457b32d6622c3985448918fa'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/pe_concat_basedir.rb]/ensure: defined content as '{md5}0ccd3500f29b9dd346a45a61268c7c18'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/pe_razor_server_version.rb]/ensure: defined content as '{md5}ec91d8b92e03d5f952c789308d26dcd0'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/pe_server_version.rb]/ensure: defined content as '{md5}17c2795fe8a56b731ae0fc81ba147e6a'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/pe_version.rb]/ensure: defined content as '{md5}b0cd9b5b3fed73bc0d6424d8ac1d6639'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/platform_symlink_writable.rb]/ensure: defined content as '{md5}fc1e2766ff9994fa5df95cdc14b9bcd2'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/platform_tag.rb]/ensure: defined content as '{md5}ba51554600d31251f66baaf81b00639a'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/puppet_files_dir_present.rb]/ensure: defined content as '{md5}3900e124be2f377638dd1522079856bf'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/staging_http_get.rb]/ensure: defined content as '{md5}2c27beb47923ce3acda673703f395e68'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/windows.rb]/ensure: defined content as '{md5}d8880f6f32905f040f3355e2a40cf088'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/face]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/face/node]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/face/node/purge.rb]/ensure: defined content as '{md5}2dc21d637a51cdb5b4e7997409eee1fc'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/feature]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/feature/pe_hocon.rb]/ensure: defined content as '{md5}bbd4eca7117850bcef6f3be059cf250c'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/feature/pe_puppet_authorization.rb]/ensure: defined content as '{md5}c673198b8d2117318558170c0a7f5ced'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/build_mcollective_metadata_cron_minute_array.rb]/ensure: defined content as '{md5}d657907920f0d58902578b23b93a7aab'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/cookie_secret_key.rb]/ensure: defined content as '{md5}a1a48191d1f0cb934b0c63d8fec70566'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/create_java_args_subsettings_hash.rb]/ensure: defined content as '{md5}b54be02c9f0b0eeee699764df57a2db3'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_any2array.rb]/ensure: defined content as '{md5}3384ea4d25dc66d898717c9ca6bb5507'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_bool2str.rb]/ensure: defined content as '{md5}f6189451331df6fd24ec69d7cdc76abe'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_build_version.rb]/ensure: defined content as '{md5}cc956210f4ef17fb396513dffdee1ed7'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_chomp.rb]/ensure: defined content as '{md5}b4f0cb35578710dc4ac315d35e9571a2'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_compile_master.rb]/ensure: defined content as '{md5}73a4baa192f4461b5d82856094bc6ffb'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_compiling_server_aio_build.rb]/ensure: defined content as '{md5}d01e0cac62411df5140da0956a79544c'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_compiling_server_version.rb]/ensure: defined content as '{md5}dfa2285cae91d2985408274b24692d69'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_concat_getparam.rb]/ensure: defined content as '{md5}46df3de760f918b120fb2254f85eff2a'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_concat_is_bool.rb]/ensure: defined content as '{md5}b511d7545ede5abae00951199b67674d'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_count.rb]/ensure: defined content as '{md5}eba067719da25b908662eec256ebc9b4'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_create_amq_augeas_command.rb]/ensure: defined content as '{md5}a62e6f52c8a5bdc002436dc6c292fd48'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_current_server_version.rb]/ensure: defined content as '{md5}f08526ad8a79c173dc0759584fb2e397'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_delete_undef_values.rb]/ensure: defined content as '{md5}c25bbcdfc6bca2d219e5f42f3eb8fa0b'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_directory_exists.rb]/ensure: defined content as '{md5}18df1a47e5e04af8278b937953bf3179'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_empty.rb]/ensure: defined content as '{md5}01a6574fab1ed1cf94ef1fea4954eeca'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_flatten.rb]/ensure: defined content as '{md5}c781954451d1860ca8f63fd6d2b6cf76'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_format_urls.rb]/ensure: defined content as '{md5}b03ddf9f0600bc0122dfe3ba814c3ba7'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_getvar.rb]/ensure: defined content as '{md5}f445be97e6541d0ae577ea5450479067'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_grep.rb]/ensure: defined content as '{md5}ae92a94aa1c964ff2af58d74df115af8'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_is_array.rb]/ensure: defined content as '{md5}b451e133e015fc7e8dc4dcfdf059a8d8'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_is_bool.rb]/ensure: defined content as '{md5}2dfe2be70aaff951b59e9fba3e85aa5d'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_is_integer.rb]/ensure: defined content as '{md5}a410ba3f3586b7df90e532b2eb99da37'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_is_string.rb]/ensure: defined content as '{md5}5fe6741e70f2bbb93a0ae43d233eeebc'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_join.rb]/ensure: defined content as '{md5}4f433ea29dffc79247671fb4271d0a10'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_join_keys_to_values.rb]/ensure: defined content as '{md5}3066c3bd5e181a996729691a57cf3d21'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_loadyaml.rb]/ensure: defined content as '{md5}6adef0c167fbe0167a8e7aec7c65317b'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_max.rb]/ensure: defined content as '{md5}e04acd17070545133c83ec5a0e11c022'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_merge.rb]/ensure: defined content as '{md5}0971d635342b84a3a5c5a40ac36d9807'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_min.rb]/ensure: defined content as '{md5}e6d2b8c614168f4224e3f76f32d9f9cb'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_pick.rb]/ensure: defined content as '{md5}06b3a9e63faf3ca5d64c65fa14803cdf'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_postgresql_acls_to_resources_hash.rb]/ensure: defined content as '{md5}851d972daf92e9e0600f8991a15311be'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_postgresql_escape.rb]/ensure: defined content as '{md5}cc58b659957328d9577336353bc246b2'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_postgresql_password.rb]/ensure: defined content as '{md5}72c33c3b7e4a6e8128fbb0a52bf30282'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_prefix.rb]/ensure: defined content as '{md5}554fcaf9362a544f91bb192047dd5341'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_puppetserver_static_content_list.rb]/ensure: defined content as '{md5}3955ef0b5cd765be892a3043386cf91f'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_servername.rb]/ensure: defined content as '{md5}c60209498856941f6f794d4c3cfb5d1f'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_size.rb]/ensure: defined content as '{md5}876097c7df6d07296524bb2236f60a1d'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_sort.rb]/ensure: defined content as '{md5}26047743025f2fdcf5e7b5420d5382ea'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_strip.rb]/ensure: defined content as '{md5}8d60a607f04fc6622eca8ae46e2fef2f'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_suffix.rb]/ensure: defined content as '{md5}a44749c5ef30e258866cb18fd83f77d2'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_to_bytes.rb]/ensure: defined content as '{md5}6ee36cabe336db4c281c7d3b1b1d771e'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_union.rb]/ensure: defined content as '{md5}da3ea966f5468bbdb8420975576d4a3f'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_unique.rb]/ensure: defined content as '{md5}5edb2c537d80f003d71a250bf203c79e'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_upcase.rb]/ensure: defined content as '{md5}4ea67e96c4da45092fb70fcdf1f0692f'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_validate_absolute_path.rb]/ensure: defined content as '{md5}d4bd539a3d7db93d4563cbbe571a16ac'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_validate_array.rb]/ensure: defined content as '{md5}0ab10b81de351aa9f6114c1880cc7155'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_validate_bool.rb]/ensure: defined content as '{md5}4a74954e0502837f11d2eadedb71bc1f'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_validate_hash.rb]/ensure: defined content as '{md5}36a223b1648dec8cb30fd229e3bb74c6'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_validate_re.rb]/ensure: defined content as '{md5}bccac35a2607bf15f1e7d1c565c1d98b'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_validate_single_integer.rb]/ensure: defined content as '{md5}ef8c455e5d58954bc4e78e36534a340c'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_validate_string.rb]/ensure: defined content as '{md5}c4d83c3ef14c2e3e47c4408d49c22437'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/pe_zip.rb]/ensure: defined content as '{md5}77f42491eaa279803a36b02601206b33'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/scope_defaults.rb]/ensure: defined content as '{md5}da916d46f3ff3be8359f75c93c2b5532'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/parser/functions/staging_parse.rb]/ensure: defined content as '{md5}605c4de803c65f2c3613653b68921002'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_file_line]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_file_line/ruby.rb]/ensure: defined content as '{md5}79d77c28f8a311684aceec3e08c1a084'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_hocon_setting]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_hocon_setting/ruby.rb]/ensure: defined content as '{md5}c0bad8a42357896675e209aab7ee6a0d'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_ini_setting]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_ini_setting/ruby.rb]/ensure: defined content as '{md5}d0520f108a6f0e55320a97f8285a0843'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_ini_subsetting]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_ini_subsetting/ruby.rb]/ensure: defined content as '{md5}7245892fe493f361b4f2fb34188e71db'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_java_ks]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_java_ks/keytool.rb]/ensure: defined content as '{md5}6e16c71a9e74550cfe9aad4ecbb8fd22'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_postgresql_conf]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_postgresql_conf/parsed.rb]/ensure: defined content as '{md5}f0e7fc6f14420d46ebf64635939243af'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_postgresql_psql]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_postgresql_psql/ruby.rb]/ensure: defined content as '{md5}68b0e90ab501fc36b821c4c27c74fb17'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_puppet_authorization_hocon_rule]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/provider/pe_puppet_authorization_hocon_rule/ruby.rb]/ensure: defined content as '{md5}1aaaa7466dc6d830cb25332cc2910c07'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type/pe_anchor.rb]/ensure: defined content as '{md5}5505f2e5850c0dd2e56583d214baf197'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type/pe_file_line.rb]/ensure: defined content as '{md5}5cecf4e63d31bc89f31a9be54a248359'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type/pe_hocon_setting.rb]/ensure: defined content as '{md5}204b2889d1c6db8f986f02ed17239ef5'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type/pe_ini_setting.rb]/ensure: defined content as '{md5}5a6ac7186c2c2be8008f128a971b104e'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type/pe_ini_subsetting.rb]/ensure: defined content as '{md5}022dc2b30ed8daa8ce2226017bc95a38'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type/pe_java_ks.rb]/ensure: defined content as '{md5}9bb59c04ff805eb7e824fc4e5b4c9767'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type/pe_postgresql_conf.rb]/ensure: defined content as '{md5}140d5cb21ae1b8554f40c71f2b73b332'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type/pe_postgresql_psql.rb]/ensure: defined content as '{md5}ffabdb11eb481e45c76795195672436c'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/type/pe_puppet_authorization_hocon_rule.rb]/ensure: defined content as '{md5}2a9e64fd982a8c0b118d0ce803c92bfb'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/util]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/util/external_iterator.rb]/ensure: defined content as '{md5}69ad1eb930ca6d8d6b6faea343b4a22e'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/util/pe_ini_file]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/util/pe_ini_file.rb]/ensure: defined content as '{md5}9ba01a79162a1d69ab8e90e725d07d3a'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/util/pe_ini_file/section.rb]/ensure: defined content as '{md5}652d2b45e5defc13fb7989f020e6080f'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/puppet/util/setting_value.rb]/ensure: defined content as '{md5}a649418f4c767d976f4bf13985575b3c'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/shared]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/shared/aio_build.rb]/ensure: defined content as '{md5}d0fe0c2b31687ea03c1ede01a460f3a0'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/shared/pe_build.rb]/ensure: defined content as '{md5}4f4652af20c4f0391b9ca2976940a710'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/shared/pe_server_version.rb]/ensure: defined content as '{md5}f3d3fc8776512ae73d3293c97b8f3dfe'
Info: Loading facts
Info: Caching catalog for agent.example.com
Info: Applying configuration version '1479159910'
Notice: /Stage[main]/Puppet_enterprise::Symlinks/File[/usr/local/bin/facter]/target: target changed '/opt/puppetlabs/puppet/bin/facter' to '/opt/puppetlabs/bin/facter'
Notice: /Stage[main]/Puppet_enterprise::Symlinks/File[/usr/local/bin/puppet]/target: target changed '/opt/puppetlabs/puppet/bin/puppet' to '/opt/puppetlabs/bin/puppet'
Notice: /Stage[main]/Puppet_enterprise::Symlinks/File[/usr/local/bin/pe-man]/target: target changed '/opt/puppetlabs/puppet/bin/pe-man' to '/opt/puppetlabs/bin/pe-man'
Notice: /Stage[main]/Puppet_enterprise::Symlinks/File[/usr/local/bin/hiera]/target: target changed '/opt/puppetlabs/puppet/bin/hiera' to '/opt/puppetlabs/bin/hiera'
Notice: /Stage[main]/Puppet_enterprise::Pxp_agent/File[/etc/puppetlabs/pxp-agent/pxp-agent.conf]/ensure: defined content as '{md5}7ad41dbd7e2345c888107f6496fd5afe'
Info: /Stage[main]/Puppet_enterprise::Pxp_agent/File[/etc/puppetlabs/pxp-agent/pxp-agent.conf]: Scheduling refresh of Service[pxp-agent]
Notice: /Stage[main]/Puppet_enterprise::Pxp_agent::Service/Service[pxp-agent]/ensure: ensure changed 'stopped' to 'running'
Info: /Stage[main]/Puppet_enterprise::Pxp_agent::Service/Service[pxp-agent]: Unscheduling refresh on Service[pxp-agent]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/agent]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/package.ddl]/ensure: defined content as '{md5}ae1d49824b9b84d1a8f617c317147bea'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/package.rb]/ensure: defined content as '{md5}60d4b37d3844fc379a99d2b17a243620'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/puppet.ddl]/ensure: defined content as '{md5}69e63795545712fd9e3d75ea1ae1d1d4'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/puppet.rb]/ensure: defined content as '{md5}8f4839ea11e4c4911e531f77f94b033b'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/puppetral.ddl]/ensure: defined content as '{md5}7f06f13953847e60818a681c1f2f168b'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/puppetral.rb]/ensure: defined content as '{md5}686272ee73d966e3f1d3482d7d7b61a8'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/service.ddl]/ensure: defined content as '{md5}3471e24142773d1bb7769c250e6b63d3'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/service.rb]/ensure: defined content as '{md5}cbf84ed615eeda9789650b05ec504566'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/aggregate]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/aggregate/boolean_summary.ddl]/ensure: defined content as '{md5}aa581c71a6c7658bffdbaec81590f65d'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/aggregate/boolean_summary.rb]/ensure: defined content as '{md5}0546063313508d8aff603be320af3c44'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/application]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/application/package.rb]/ensure: defined content as '{md5}4e6571cdac3f6aa322c9f195693e1dbe'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/application/puppet.rb]/ensure: defined content as '{md5}e8085d91ddaa1f92984bde5d34cc47d5'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/application/service.rb]/ensure: defined content as '{md5}c95359f947af5f0d904fa3df80cb9820'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/data]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/data/puppet_data.ddl]/ensure: defined content as '{md5}5c9912bf5ae5dbc8762109a40c027c63'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/data/puppet_data.rb]/ensure: defined content as '{md5}606e87cd509addf22dd8e93d503d8262'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/data/resource_data.ddl]/ensure: defined content as '{md5}c4e3a46fd3c0b5d3990db0b8af1c747f'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/data/resource_data.rb]/ensure: defined content as '{md5}49be769fb403191af41f1b89697ce4cc'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/data/service_data.ddl]/ensure: defined content as '{md5}e7f7e0bc65ede56fc636505a400b1700'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/data/service_data.rb]/ensure: defined content as '{md5}bc651898c7dcd373d609c933fbd6021f'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/mco_plugin_versions]/ensure: defined content as '{md5}c96b3a9206e43f8c3a0550731dd3b739'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/registration]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/registration/meta.rb]/ensure: defined content as '{md5}e939958bbbc0817e1779c336037e1849'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/security]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/security/sshkey.ddl]/ensure: defined content as '{md5}e92b26732d03496fb61ad3a1ed623f56'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/security/sshkey.rb]/ensure: defined content as '{md5}c3933bda744b78dd857f20aa5b61f75b'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/actionpolicy.rb]/ensure: defined content as '{md5}e4d6a7024ad7b28e019e7b9931eac027'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/package]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/package/base.rb]/ensure: defined content as '{md5}1bdb7e7a6dcfea6fd2a06c5dc39b7276'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/package/packagehelpers.rb]/ensure: defined content as '{md5}312aecc3b1ee75f97a989fea3e7a221d'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/package/puppetpackage.rb]/ensure: defined content as '{md5}865eec36ae05c30b072d3f5bd871fb52'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/package/yumHelper.py]/ensure: defined content as '{md5}40fa99ef10b84c38517f6b695a0af533'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/package/yumpackage.rb]/ensure: defined content as '{md5}256bde1567d8794ca929092462f5ae03'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/puppet_agent_mgr]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/puppet_agent_mgr.rb]/ensure: defined content as '{md5}4dbafcaa02334c2d76665cd23ca29688'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/puppet_agent_mgr/mgr_v2.rb]/ensure: defined content as '{md5}9a00171022ddb12d0a463e9cefeba481'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/puppet_agent_mgr/mgr_v3.rb]/ensure: defined content as '{md5}b5cb1a9b7311fc3769a3ccaabadeb694'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/puppet_agent_mgr/mgr_windows.rb]/ensure: defined content as '{md5}79a6cf3dac0177f6b9c22d5085324676'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/puppet_server_address_validation.rb]/ensure: defined content as '{md5}1c78390e33e71773e121a902ae91bfd4'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/puppetrunner.rb]/ensure: defined content as '{md5}a4fade81457455fbca9370249defbdf1'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/service]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/service/base.rb]/ensure: defined content as '{md5}abea7b8fadbf3425a7b68b49b9435ff6'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/util/service/puppetservice.rb]/ensure: defined content as '{md5}905db93e1c06ad5a7154fa2f9199f31c'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/puppet_resource_validator.ddl]/ensure: defined content as '{md5}3e45a28e1ba6c8d22ce40934c04b30b4'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/puppet_resource_validator.rb]/ensure: defined content as '{md5}567c7dc4d70ed0db7fd2626c77f6df41'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/puppet_server_address_validator.ddl]/ensure: defined content as '{md5}323e0b9647639fdf32cfbc63a82860f7'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/puppet_server_address_validator.rb]/ensure: defined content as '{md5}e84a56187809c5181b78b2819ee149fe'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/puppet_tags_validator.ddl]/ensure: defined content as '{md5}7ed95b2e5b210db83d12d5034f1ecb0f'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/puppet_tags_validator.rb]/ensure: defined content as '{md5}40b29498e867ba2ecf21dc08bc457d4e'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/puppet_variable_validator.ddl]/ensure: defined content as '{md5}58c9db4ca4503e4d692a016743e01627'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/puppet_variable_validator.rb]/ensure: defined content as '{md5}3cbca3af2e5884f2a807ef005a87151b'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/service_name.ddl]/ensure: defined content as '{md5}2812afa15108103042f706c2201e286b'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/service_name.rb]/ensure: defined content as '{md5}3f501a9ed252ce2dfe06a2e1e53845ab'
Info: /opt/puppetlabs/mcollective/plugins/mcollective: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Logs/File[/var/log/puppetlabs/mcollective.log]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Logs/File[/var/log/puppetlabs/mcollective-audit.log]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl]/ensure: created
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/clients]/ensure: created
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/clients]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/ca.cert.pem]/ensure: defined content as '{md5}e3aa47a940ec4d56b40cdd3a67f9a60e'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/ca.cert.pem]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/agent.example.com.cert.pem]/ensure: defined content as '{md5}0f3acc9a7204aa22df878bfc46a401e8'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/agent.example.com.cert.pem]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/agent.example.com.private_key.pem]/ensure: defined content as '{md5}532136e0394bdd61314273a6f905f5e7'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/agent.example.com.private_key.pem]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/mcollective-private.pem]/ensure: defined content as '{md5}63d793c924bcc349d5c3632a35d980b6'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/mcollective-private.pem]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/mcollective-public.pem]/ensure: defined content as '{md5}bfed7e0a0c10eb1120ae265cd60e55fd'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/mcollective-public.pem]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/clients/puppet-dashboard-public.pem]/ensure: defined content as '{md5}d41d8cd98f00b204e9800998ecf8427e'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/clients/puppet-dashboard-public.pem]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/clients/peadmin-public.pem]/ensure: defined content as '{md5}81569970c95d5fc36161532eb93cef18'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/clients/peadmin-public.pem]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Facter/File[/opt/puppetlabs/puppet/bin/refresh-mcollective-metadata]/ensure: defined content as '{md5}6daa27a4146a20dea32f525f725563a1'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Facter/Exec[bootstrap mcollective metadata]/returns: executed successfully
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Facter/Cron[pe-mcollective-metadata]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Facter/File[/etc/puppetlabs/mcollective/facts-bootstrapped]/ensure: created
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server::Facter/File[/etc/puppetlabs/mcollective/facts-bootstrapped]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]/content:
--- /etc/puppetlabs/mcollective/server.cfg    2016-10-12 02:58:21.000000000 +0000
+++ /tmp/puppet-file20161114-4747-13xcmul    2016-11-14 21:45:16.440205999 +0000
@@ -1,27 +1,83 @@
-main_collective = mcollective
-collectives = mcollective
-
-libdir = /opt/puppetlabs/mcollective/plugins
-
-# consult the "classic" libdirs too
-libdir = /usr/share/mcollective/plugins
-libdir = /usr/libexec/mcollective

-logfile = /var/log/puppetlabs/mcollective.log
-loglevel = info
-daemonize = 1
-
-# Plugins
-securityprovider = psk
-plugin.psk = unset
+# Centrally managed by Puppet version 4.7.0
+# https://docs.puppetlabs.com/mcollective/configure/server.html

+# Connector settings (required):
+# -----------------------------
 connector = activemq
+direct_addressing = 1
+
+# ActiveMQ connector settings:
+plugin.activemq.randomize = false
 plugin.activemq.pool.size = 1
-plugin.activemq.pool.1.host = stomp1
-plugin.activemq.pool.1.port = 6163
+plugin.activemq.pool.1.host = puppet.example.com
+plugin.activemq.pool.1.port = 61613
 plugin.activemq.pool.1.user = mcollective
-plugin.activemq.pool.1.password = marionette
+plugin.activemq.pool.1.password = QqSrsBgYn01bfW6RmX0m3Q
+plugin.activemq.pool.1.ssl = true
+plugin.activemq.pool.1.ssl.ca = /etc/puppetlabs/mcollective/ssl/ca.cert.pem
+plugin.activemq.pool.1.ssl.cert = /etc/puppetlabs/mcollective/ssl/agent.example.com.cert.pem
+plugin.activemq.pool.1.ssl.key = /etc/puppetlabs/mcollective/ssl/agent.example.com.private_key.pem
+plugin.activemq.heartbeat_interval = 120
+plugin.activemq.max_hbrlck_fails = 0
+
+# Security plugin settings (required):
+# -----------------------------------
+securityprovider           = ssl
+
+# SSL plugin settings:
+plugin.ssl_server_private  = /etc/puppetlabs/mcollective/ssl/mcollective-private.pem
+plugin.ssl_server_public   = /etc/puppetlabs/mcollective/ssl/mcollective-public.pem
+plugin.ssl_client_cert_dir = /etc/puppetlabs/mcollective/ssl/clients
+plugin.ssl_serializer      = yaml

-# Facts
+# Facts, identity, and classes (recommended):
+# ------------------------------------------
 factsource = yaml
 plugin.yaml = /etc/puppetlabs/mcollective/facts.yaml
+fact_cache_time = 300
+
+identity = agent.example.com
+
+classesfile = /opt/puppetlabs/puppet/cache/state/classes.txt
+
+# Registration (recommended):
+# -----------------------
+registration = Meta
+registerinterval = 600
+
+# Subcollectives (optional):
+# -------------------------
+main_collective = mcollective
+collectives     = mcollective
+
+# Auditing (optional):
+# -------------------
+plugin.rpcaudit.logfile = /var/log/puppetlabs/mcollective-audit.log
+rpcaudit = 1
+rpcauditprovider = logfile
+
+# Authorization (optional):
+# ------------------------
+plugin.actionpolicy.allow_unconfigured = 1
+rpcauthorization = 1
+rpcauthprovider = action_policy
+
+# Logging:
+# -------
+logfile  = /var/log/puppetlabs/mcollective.log
+loglevel = info
+
+# Platform defaults:
+# -----------------
+daemonize = 1
+libdir = /opt/puppet/libexec/mcollective:/opt/puppetlabs/mcollective/plugins
+
+# Puppet Agent plugin configuration:
+# ---------------------------------
+plugin.puppet.splay = true
+plugin.puppet.splaylimit = 120
+plugin.puppet.signal_daemon = 0
+plugin.puppet.command = /opt/puppetlabs/bin/puppet agent
+plugin.puppet.config  = /etc/puppetlabs/puppet/puppet.conf
+

Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]/content: content changed '{md5}73e68cfd79153a49de6f5721ab60657b' to '{md5}cb398b5c245a57431f44a9b941bd246d'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]/mode: mode changed '0644' to '0660'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]: Scheduling refresh of Service[mcollective]
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]: Scheduling refresh of Service[mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Service/Service[mcollective]/ensure: ensure changed 'stopped' to 'running'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Service/Service[mcollective]: Unscheduling refresh on Service[mcollective]
Notice: Applied catalog in 4.21 seconds
```

Followed by another run...  (clean, and no changes.)

```
[root@agent ~]# puppet agent -t
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for agent.example.com
Info: Applying configuration version '1479159923'
Notice: Applied catalog in 0.63 seconds
```

---

Back to **Lab #4** --> [Install Puppet Agent](04-Install-Puppet-Agent.md#run-the-puppet-agent-again)

---

Continue to **Lab #5** --> [Get familiar with puppet config files, and puppet code, and CLI](05-Puppet-Config-and-Code.md#lab-5)

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

