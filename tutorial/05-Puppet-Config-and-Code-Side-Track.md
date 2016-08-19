
Also, Out-of-the-Box you'll find some pre-created empty directories at the "top level" /etc/puppetlabs/puppet

     /etc/puppetlabs/puppet
     ├── files
     ├── manifests
     ├── modules

Some of these same directories are also used within each puppet module.  (A
module is just a bit of puppet code bundled up in a well-defined way, so that
it can be distributed, and used by other people easily.)  We'll learn more
about modules later, but for now just remember that the use of each directory
is well defined, and you shouldn't just use them for whatever you want:

* files - used for static files that your puppet code may reference
* manifests - where your site.pp lives, and potentially other site-developed code
* modules - any puppet modules you use go here, including site-developed modules
* templates - similar to the files dir, but hold marked up files in ERB format

In the case of the top-level directories, you may not actually use them very
much, or at all.  It's more likely you'll use the environment-specific set
of directories.  Each individual environment has its own files, manifests,
modules, and templates directories.

The top-level set of directories could be used to hold puppet code that would
be used globally across all environments.  However, OOTB Puppet Enterprise comes
configured with one environment called **production**, and the site manifest
installed under **environments/production/manifests/site.pp**  There are some
use cases for these directories (files, manifests, modules, and templates) at
the "top-level" or "global level", but in all likelyhood, they wont be used.
The typical new-install these days uses the environment-specific directories,
and often wont use the "global" set of directories at all.

     /etc/puppetlabs/puppet
     ├── environments
     │   └── production
     │       ├── manifests
     │       │   └── site.pp
     │       └── modules
     ├── puppet.conf

Note: The default **modulepath** does include /etc/puppetlabs/puppet/modules, so we could certainly install
modules there as well if we wish to use the same version across all environments.  A module of the same name,
installed within the environment would however override the one installed at the "site level", as the
modulepath is defined (by default) as follows:

```
# puppet config print modulepath
/etc/puppetlabs/puppet/environments/production/modules:/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules
```

Knowing this, one potential use case would be to install a "base" version of a module in puppet/modules, and then as
individual environments require a newer version, you could install it on a per-environment basis.  At some point, if all
environemnts are on a significantly newer version, you could upgrade the module version in puppet/modules to match
whatever the oldest version of the bunch is, and that could be you new baseline (say, for any new environments that are
created, that do not yet have their own environment-specific version.)  They could be useful in a Dev Shop where there
is constant change, and many different version of things at different points in the development pipeline.

Each environment gets its own directory within the **environments** directory,
and each environment contains it's own set of manifests, modules, files
and templates.

### The modules directory ###

The modules directory can contain additional Puppet code from PuppetLabs or
other third parties, or even in-house modules.  One common module that is used by a lot of other
Puppet modules is **stdlib**.  It is a sort of "utility module" that adds on additional blades to
your swiss army knife in the form of resource types and functions.  It is also a PuppetLabs-supported module.


