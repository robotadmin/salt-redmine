## Salt recipe for installing redmine

Currently halfway. Creates a redmine user and installs rvm and rails in a specific gemset for the redmine install. To be finished.
 
--------------------

### Note

I tried to install rails using salt.states.gem, by doing the following:

```yaml
rails:
  gem.installed:
    - runas: redmine
    - version: 3.2.13
    - ruby: 2.0.0@redmine_rails3.2.13
```

But it fails with return code 127, which means that it is not using the rvm of user redmine. Will try to see what is happening.
