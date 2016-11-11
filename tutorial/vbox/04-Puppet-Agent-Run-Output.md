
Here's the output from the inital puppet run on the **agent** VM...

```
[root@agent ~]# puppet agent -t
Info: Caching certificate for agent.example.com
Info: Caching certificate_revocation_list for ca
Info: Caching certificate for agent.example.com
Warning: Unable to fetch my node definition, but the agent run will continue:
Warning: undefined method `include?' for nil:NilClass
Info: Retrieving pluginfacts
Info: Retrieving plugin
Notice: /File[/var/opt/lib/pe-puppet/lib/facter]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/custom_auth_conf.rb]/ensure: defined content as '{md5}45f759978989686d9820efb73a0d277c'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/pe_build.rb]/ensure: defined content as '{md5}f2a752162694029797947d0f88a50def'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/pe_concat_basedir.rb]/ensure: defined content as '{md5}0ccd3500f29b9dd346a45a61268c7c18'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/pe_version.rb]/ensure: defined content as '{md5}4a9353952963b011759f3e6652a10da5'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/platform_symlink_writable.rb]/ensure: defined content as '{md5}1642c4dde30573c1929305f9bfb349fa'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/platform_tag.rb]/ensure: defined content as '{md5}ba0af12f6068589e99afce76072d8bf6'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/staging_http_get.rb]/ensure: defined content as '{md5}2c27beb47923ce3acda673703f395e68'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/windows.rb]/ensure: defined content as '{md5}d8880f6f32905f040f3355e2a40cf088'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/indirector]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/indirector/node]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/indirector/node/console.rb]/ensure: defined content as '{md5}40a74c14f2748b93da7339fa011cc110'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/cookie_secret_key.rb]/ensure: defined content as '{md5}a1a48191d1f0cb934b0c63d8fec70566'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/create_java_args_subsettings_hash.rb]/ensure: defined content as '{md5}b54be02c9f0b0eeee699764df57a2db3'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_bool2str.rb]/ensure: defined content as '{md5}f6189451331df6fd24ec69d7cdc76abe'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_chomp.rb]/ensure: defined content as '{md5}b4f0cb35578710dc4ac315d35e9571a2'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_concat_getparam.rb]/ensure: defined content as '{md5}46df3de760f918b120fb2254f85eff2a'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_concat_is_bool.rb]/ensure: defined content as '{md5}b511d7545ede5abae00951199b67674d'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_create_amq_augeas_command.rb]/ensure: defined content as '{md5}a62e6f52c8a5bdc002436dc6c292fd48'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_delete_undef_values.rb]/ensure: defined content as '{md5}c25bbcdfc6bca2d219e5f42f3eb8fa0b'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_empty.rb]/ensure: defined content as '{md5}01a6574fab1ed1cf94ef1fea4954eeca'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_flatten.rb]/ensure: defined content as '{md5}c781954451d1860ca8f63fd6d2b6cf76'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_getvar.rb]/ensure: defined content as '{md5}f870b47cd38f515662c29555a7c6e91f'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_is_array.rb]/ensure: defined content as '{md5}b451e133e015fc7e8dc4dcfdf059a8d8'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_is_bool.rb]/ensure: defined content as '{md5}2dfe2be70aaff951b59e9fba3e85aa5d'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_is_integer.rb]/ensure: defined content as '{md5}a410ba3f3586b7df90e532b2eb99da37'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_is_string.rb]/ensure: defined content as '{md5}5fe6741e70f2bbb93a0ae43d233eeebc'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_join.rb]/ensure: defined content as '{md5}4f433ea29dffc79247671fb4271d0a10'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_join_keys_to_values.rb]/ensure: defined content as '{md5}3066c3bd5e181a996729691a57cf3d21'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_loadyaml.rb]/ensure: defined content as '{md5}6adef0c167fbe0167a8e7aec7c65317b'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_max.rb]/ensure: defined content as '{md5}e04acd17070545133c83ec5a0e11c022'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_min.rb]/ensure: defined content as '{md5}e6d2b8c614168f4224e3f76f32d9f9cb'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_pick.rb]/ensure: defined content as '{md5}06b3a9e63faf3ca5d64c65fa14803cdf'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_postgresql_acls_to_resources_hash.rb]/ensure: defined content as '{md5}851d972daf92e9e0600f8991a15311be'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_postgresql_escape.rb]/ensure: defined content as '{md5}cc58b659957328d9577336353bc246b2'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_postgresql_password.rb]/ensure: defined content as '{md5}72c33c3b7e4a6e8128fbb0a52bf30282'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_prefix.rb]/ensure: defined content as '{md5}554fcaf9362a544f91bb192047dd5341'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_strip.rb]/ensure: defined content as '{md5}8d60a607f04fc6622eca8ae46e2fef2f'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_suffix.rb]/ensure: defined content as '{md5}a44749c5ef30e258866cb18fd83f77d2'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_to_bytes.rb]/ensure: defined content as '{md5}6ee36cabe336db4c281c7d3b1b1d771e'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_union.rb]/ensure: defined content as '{md5}da3ea966f5468bbdb8420975576d4a3f'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_unique.rb]/ensure: defined content as '{md5}5edb2c537d80f003d71a250bf203c79e'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_upcase.rb]/ensure: defined content as '{md5}4ea67e96c4da45092fb70fcdf1f0692f'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_validate_absolute_path.rb]/ensure: defined content as '{md5}d4bd539a3d7db93d4563cbbe571a16ac'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_validate_array.rb]/ensure: defined content as '{md5}0ab10b81de351aa9f6114c1880cc7155'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_validate_bool.rb]/ensure: defined content as '{md5}4a74954e0502837f11d2eadedb71bc1f'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_validate_hash.rb]/ensure: defined content as '{md5}36a223b1648dec8cb30fd229e3bb74c6'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_validate_re.rb]/ensure: defined content as '{md5}bccac35a2607bf15f1e7d1c565c1d98b'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_validate_single_integer.rb]/ensure: defined content as '{md5}ef8c455e5d58954bc4e78e36534a340c'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/pe_validate_string.rb]/ensure: defined content as '{md5}c4d83c3ef14c2e3e47c4408d49c22437'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/scope_defaults.rb]/ensure: defined content as '{md5}da916d46f3ff3be8359f75c93c2b5532'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/parser/functions/staging_parse.rb]/ensure: defined content as '{md5}605c4de803c65f2c3613653b68921002'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_file_line]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_file_line/ruby.rb]/ensure: defined content as '{md5}79d77c28f8a311684aceec3e08c1a084'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_ini_setting]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_ini_setting/ruby.rb]/ensure: defined content as '{md5}d0520f108a6f0e55320a97f8285a0843'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_ini_subsetting]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_ini_subsetting/ruby.rb]/ensure: defined content as '{md5}7245892fe493f361b4f2fb34188e71db'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_java_ks]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_java_ks/keytool.rb]/ensure: defined content as '{md5}6e16c71a9e74550cfe9aad4ecbb8fd22'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_postgresql_conf]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_postgresql_conf/parsed.rb]/ensure: defined content as '{md5}f0e7fc6f14420d46ebf64635939243af'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_postgresql_psql]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/provider/pe_postgresql_psql/ruby.rb]/ensure: defined content as '{md5}3f7e99833784bdaf4c56c9d8621aa14c'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/reports]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/reports/console.rb]/ensure: defined content as '{md5}4a1a445c9315e0dff869533dca8b6840'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/type]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/type/pe_anchor.rb]/ensure: defined content as '{md5}5505f2e5850c0dd2e56583d214baf197'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/type/pe_file_line.rb]/ensure: defined content as '{md5}5cecf4e63d31bc89f31a9be54a248359'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/type/pe_ini_setting.rb]/ensure: defined content as '{md5}51ff3999c8dfd3a32303c14deb279dc4'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/type/pe_ini_subsetting.rb]/ensure: defined content as '{md5}022dc2b30ed8daa8ce2226017bc95a38'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/type/pe_java_ks.rb]/ensure: defined content as '{md5}5fa3ea1d3972859574bbdcbd1049cb3d'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/type/pe_postgresql_conf.rb]/ensure: defined content as '{md5}7525790ec89f646dd377655a7e87e6eb'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/type/pe_postgresql_psql.rb]/ensure: defined content as '{md5}ffabdb11eb481e45c76795195672436c'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/util]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/util/external_iterator.rb]/ensure: defined content as '{md5}69ad1eb930ca6d8d6b6faea343b4a22e'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/util/pe_ini_file]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/util/pe_ini_file.rb]/ensure: defined content as '{md5}9ba01a79162a1d69ab8e90e725d07d3a'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/util/pe_ini_file/section.rb]/ensure: defined content as '{md5}652d2b45e5defc13fb7989f020e6080f'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppet/util/setting_value.rb]/ensure: defined content as '{md5}a649418f4c767d976f4bf13985575b3c'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppetpe]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppetpe/puppetlabs]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppetpe/puppetlabs/pe_console]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/puppetpe/puppetlabs/pe_console/config.rb]/ensure: defined content as '{md5}5ef248d7814aa1df12cb44db77d11771'
Notice: /File[/var/opt/lib/pe-puppet/lib/puppetpe/puppetlabs/pe_console/console_http.rb]/ensure: defined content as '{md5}b7525f7af33b49ac101aaa062ec09423'
Info: Loading facts
Info: Caching catalog for agent.example.com
Info: Applying configuration version '1477073951'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/agent/package.ddl]/ensure: defined content as '{md5}ae1d49824b9b84d1a8f617c317147bea'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/agent/package.rb]/ensure: defined content as '{md5}60d4b37d3844fc379a99d2b17a243620'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/agent/puppet.ddl]/ensure: defined content as '{md5}05d975cbc1eb09af4522462a4afd55fa'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/agent/puppet.rb]/ensure: defined content as '{md5}eb38cadaf62e34387d10783df4754cb2'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/agent/puppetral.ddl]/ensure: defined content as '{md5}7f06f13953847e60818a681c1f2f168b'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/agent/puppetral.rb]/ensure: defined content as '{md5}5bc9d72845574a3fc08c9062b4b28dd3'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/agent/service.ddl]/ensure: defined content as '{md5}3471e24142773d1bb7769c250e6b63d3'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/agent/service.rb]/ensure: defined content as '{md5}cbf84ed615eeda9789650b05ec504566'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/aggregate]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/aggregate/boolean_summary.ddl]/ensure: defined content as '{md5}aa581c71a6c7658bffdbaec81590f65d'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/aggregate/boolean_summary.rb]/ensure: defined content as '{md5}0546063313508d8aff603be320af3c44'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/application]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/application/package.rb]/ensure: defined content as '{md5}4e6571cdac3f6aa322c9f195693e1dbe'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/application/puppet.rb]/ensure: defined content as '{md5}13731d27f1276cdd3314f7fa30aa5eb1'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/application/service.rb]/ensure: defined content as '{md5}c95359f947af5f0d904fa3df80cb9820'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/data/puppet_data.ddl]/ensure: defined content as '{md5}5c9912bf5ae5dbc8762109a40c027c63'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/data/puppet_data.rb]/ensure: defined content as '{md5}606e87cd509addf22dd8e93d503d8262'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/data/resource_data.ddl]/ensure: defined content as '{md5}c4e3a46fd3c0b5d3990db0b8af1c747f'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/data/resource_data.rb]/ensure: defined content as '{md5}49be769fb403191af41f1b89697ce4cc'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/data/service_data.ddl]/ensure: defined content as '{md5}e7f7e0bc65ede56fc636505a400b1700'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/data/service_data.rb]/ensure: defined content as '{md5}bc651898c7dcd373d609c933fbd6021f'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/mco_plugin_versions]/ensure: defined content as '{md5}fd5ddfbe4d3979ccf59b6e6c7537259e'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/registration/meta.rb]/ensure: defined content as '{md5}e939958bbbc0817e1779c336037e1849'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/security/sshkey.ddl]/ensure: defined content as '{md5}e92b26732d03496fb61ad3a1ed623f56'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/security/sshkey.rb]/ensure: defined content as '{md5}c3933bda744b78dd857f20aa5b61f75b'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/actionpolicy.rb]/ensure: defined content as '{md5}e4d6a7024ad7b28e019e7b9931eac027'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/package]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/package/base.rb]/ensure: defined content as '{md5}1bdb7e7a6dcfea6fd2a06c5dc39b7276'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/package/packagehelpers.rb]/ensure: defined content as '{md5}312aecc3b1ee75f97a989fea3e7a221d'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/package/puppetpackage.rb]/ensure: defined content as '{md5}865eec36ae05c30b072d3f5bd871fb52'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/package/yumHelper.py]/ensure: defined content as '{md5}40fa99ef10b84c38517f6b695a0af533'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/package/yumpackage.rb]/ensure: defined content as '{md5}256bde1567d8794ca929092462f5ae03'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/puppet_agent_mgr]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/puppet_agent_mgr.rb]/ensure: defined content as '{md5}8b80e880a2035fb1b9167106087ff049'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/puppet_agent_mgr/mgr_v2.rb]/ensure: defined content as '{md5}9a00171022ddb12d0a463e9cefeba481'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/puppet_agent_mgr/mgr_v3.rb]/ensure: defined content as '{md5}b5cb1a9b7311fc3769a3ccaabadeb694'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/puppet_agent_mgr/mgr_windows.rb]/ensure: defined content as '{md5}79a6cf3dac0177f6b9c22d5085324676'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/puppet_server_address_validation.rb]/ensure: defined content as '{md5}1c78390e33e71773e121a902ae91bfd4'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/puppetrunner.rb]/ensure: defined content as '{md5}a4fade81457455fbca9370249defbdf1'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/service]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/service/base.rb]/ensure: defined content as '{md5}abea7b8fadbf3425a7b68b49b9435ff6'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/util/service/puppetservice.rb]/ensure: defined content as '{md5}905db93e1c06ad5a7154fa2f9199f31c'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/puppet_resource_validator.ddl]/ensure: defined content as '{md5}3e45a28e1ba6c8d22ce40934c04b30b4'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/puppet_resource_validator.rb]/ensure: defined content as '{md5}567c7dc4d70ed0db7fd2626c77f6df41'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/puppet_server_address_validator.ddl]/ensure: defined content as '{md5}323e0b9647639fdf32cfbc63a82860f7'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/puppet_server_address_validator.rb]/ensure: defined content as '{md5}e84a56187809c5181b78b2819ee149fe'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/puppet_tags_validator.ddl]/ensure: defined content as '{md5}7ed95b2e5b210db83d12d5034f1ecb0f'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/puppet_tags_validator.rb]/ensure: defined content as '{md5}40b29498e867ba2ecf21dc08bc457d4e'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/puppet_variable_validator.ddl]/ensure: defined content as '{md5}58c9db4ca4503e4d692a016743e01627'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/puppet_variable_validator.rb]/ensure: defined content as '{md5}3cbca3af2e5884f2a807ef005a87151b'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/service_name.ddl]/ensure: defined content as '{md5}2812afa15108103042f706c2201e286b'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Plugins/File[/opt/puppet/libexec/mcollective/mcollective/validator/service_name.rb]/ensure: defined content as '{md5}3f501a9ed252ce2dfe06a2e1e53845ab'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Logs/File[/var/log/pe-mcollective/mcollective.log]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Logs/File[/var/log/pe-mcollective/mcollective-audit.log]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl]/mode: mode changed '0755' to '0770'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/clients]/mode: mode changed '0755' to '0770'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/ca.cert.pem]/ensure: defined content as '{md5}c8a55414293833a34e2aced864eebc0d'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/agent.example.com.cert.pem]/ensure: defined content as '{md5}bf089f6564db7c9ab7d7e9b0672d3659'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/agent.example.com.private_key.pem]/ensure: defined content as '{md5}2e94d14dcd49ef55c066a1059a3f70dc'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/mcollective-private.pem]/ensure: defined content as '{md5}1c45c2ca69948a4b1cdfb6e8dc1347b3'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/mcollective-public.pem]/ensure: defined content as '{md5}d8ffb426830649f65d6562713646d60f'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/clients/puppet-dashboard-public.pem]/ensure: defined content as '{md5}d4baf7f4ff92815f8945788e9775a9ff'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Certs/File[/etc/puppetlabs/mcollective/ssl/clients/peadmin-public.pem]/ensure: defined content as '{md5}8aed78708b6f8eda18a8446f69b230cf'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Facter/File[/opt/puppet/sbin/refresh-mcollective-metadata]/ensure: defined content as '{md5}3d950cdcfcc2d77efc84909b191eaeea'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server::Facter/Cron[pe-mcollective-metadata]/ensure: created
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]/content:
--- /etc/puppetlabs/mcollective/server.cfg    2016-08-04 20:38:01.000000000 +0000
+++ /tmp/puppet-file20161021-942-1tpccs8    2016-10-21 18:19:12.098183023 +0000
@@ -1,22 +1,81 @@
-main_collective = mcollective
-collectives = mcollective
-libdir = /opt/puppet/libexec/mcollective/
-logfile = /var/log/pe-mcollective
-loglevel = info
-daemonize = 1

-# Plugins
-securityprovider = psk
-plugin.psk = unset
+# Centrally managed by Puppet version 3.8.7 (Puppet Enterprise 3.8.6)
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
+plugin.activemq.pool.1.password = qpH7xBfIkeEEAFDvGD6R
+plugin.activemq.pool.1.ssl = true
+plugin.activemq.pool.1.ssl.ca = /etc/puppetlabs/mcollective/ssl/ca.cert.pem
+plugin.activemq.pool.1.ssl.cert = /etc/puppetlabs/mcollective/ssl/agent.example.com.cert.pem
+plugin.activemq.pool.1.ssl.key = /etc/puppetlabs/mcollective/ssl/agent.example.com.private_key.pem
+plugin.activemq.heartbeat_interval = 120
+plugin.activemq.max_hbrlck_fails = 0

-# Facts
+# Security plugin settings (required):
+# -----------------------------------
+securityprovider           = ssl
+
+# SSL plugin settings:
+plugin.ssl_server_private  = /etc/puppetlabs/mcollective/ssl/mcollective-private.pem
+plugin.ssl_server_public   = /etc/puppetlabs/mcollective/ssl/mcollective-public.pem
+plugin.ssl_client_cert_dir = /etc/puppetlabs/mcollective/ssl/clients
+plugin.ssl_serializer      = yaml
+
+# Facts, identity, and classes (recommended):
+# ------------------------------------------
 factsource = yaml
-plugin.yaml = /etc/mcollective/facts.yaml
+plugin.yaml = /etc/puppetlabs/mcollective/facts.yaml
+
+identity = agent.example.com
+
+classesfile = /var/opt/lib/pe-puppet/classes.txt
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
+plugin.rpcaudit.logfile = /var/log/pe-mcollective/mcollective-audit.log
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
+logfile  = /var/log/pe-mcollective/mcollective.log
+loglevel = info
+
+# Platform defaults:
+# -----------------
+daemonize = 1
+libdir = /opt/puppet/libexec/mcollective/

+# Puppet Agent plugin configuration:
+# ---------------------------------
+plugin.puppet.splay = true
+plugin.puppet.splaylimit = 120
+plugin.puppet.signal_daemon = 0
+plugin.puppet.command = /opt/puppet/bin/puppet agent
+plugin.puppet.config  = /etc/puppetlabs/puppet/puppet.conf

Info: Computing checksum on file /etc/puppetlabs/mcollective/server.cfg
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]: Filebucketed /etc/puppetlabs/mcollective/server.cfg to main with sum c0feb345f525816545d9a23ec41469ff
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]/content: content changed '{md5}c0feb345f525816545d9a23ec41469ff' to '{md5}ae3d3e1f06f4c6cc7da3173935d70dff'
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]/mode: mode changed '0644' to '0660'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]: Scheduling refresh of Service[pe-mcollective]
Info: /Stage[main]/Puppet_enterprise::Mcollective::Server/File[/etc/puppetlabs/mcollective/server.cfg]: Scheduling refresh of Service[pe-mcollective]
Notice: /Stage[main]/Puppet_enterprise::Mcollective::Service/Service[pe-mcollective]/ensure: ensure changed 'stopped' to 'running'
Info: /Stage[main]/Puppet_enterprise::Mcollective::Service/Service[pe-mcollective]: Unscheduling refresh on Service[pe-mcollective]
Notice: Finished catalog run in 1.73 seconds

```

Here's the second puppet run.  Notice no more changes are applied.

```
[root@agent ~]# puppet agent -t
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for agent.example.com
Info: Applying configuration version '1477073989'
Notice: Finished catalog run in 0.33 seconds

```

---

Back to **Lab #4** --> [Install Puppet Agent](04-Install-Puppet-Agent.md#run-the-puppet-agent-again)

---

Continue to **Lab #5** --> [Get familiar with puppet config files, and puppet code, and CLI](05-Puppet-Config-and-Code.md#lab-5)

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley


