# Startup Guide
---------------

- [Install **rbenv**](https://github.com/rbenv/rbenv#installation) (or **rvm** but we're assuming **rbenv** for the sake of the guide)

- Run `ruby-build` (bundled with **rbenv**)

- Initialize **rbenv**: `rbenv init` then follow the directions it outputs. It will look something like:

```
    # Load rbenv automatically by appending
    # the following to ~/.zshrc:

    eval "$(rbenv init -)"
```

- Install **ruby** 2.5.1: `rbenv install 2.5.1`. This could take awhile.

- Update **rbenv**'s shims: `rbenv rehash`

- Install **rails**: `gem install rails`

- Install the **bundler**: `gem install bundler`

- You may need to install **Xcode** command line tools (`xcode-select --install`)

- Install **mongodb**: `brew install mongodb`

- Make the database directory: ``sudo mkdir -p /data/db && sudo chown -R `id -un` /data/db``

- Install **yarn**: `npm install -g yarn` (this assumes you have **node** and **npm** installed)

- Install the **node** packages: `yarn`

- Install the **ruby** packages: `bundle install`

- Start the **mongodb** database: `mongod`

- In a separate shell instance, create and setup the database: `rake db:create && rake db:setup`

- Start the **rails** server: `rails s`

- Start the server and dev processes: `foreman start -p 3000` (Or if that's giving you trouble, `ruby ./bin/webpack-dev-server`)


# Workflow

-----------

- Make sure your packages are updated: `yarn` and `bundle install`

- Start the **mongodb** database: `mongod`

- In a new instance, setup database: `rake db:setup && rake db:create_indexes`

- In another new instance, start the **rails** server: `rails s`

- In another new instance, start the server and dev processes: `foreman start -p 3000` (Or if that's giving you trouble, `ruby ./bin/webpack-dev-server`)
