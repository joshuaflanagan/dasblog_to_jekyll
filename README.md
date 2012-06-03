## dasblog_to_jekyll

This is a tool for migrating [DasBlog](http://dasblog.info/) content to [Jekyll](https://github.com/mojombo/jekyll).

This repo is a fork of [DasBlog2toto](https://github.com/follesoe/DasBlog2totoMigration)
(which was forked from [goeran](https://github.com/goeran/DasBlog2totoMigration))

I made very few changes to get output compatible with Jekyll. However, I
made no attempt to keep compatibility with the toto output. In most
cases, I added new code, instead of changing existing code, so if anyone
gets a crazy idea to build a more robust DasBlogTo* migrator, it
shouldn't be too hard.

### Usage

1. Copy config.yaml.sample to config.yaml
2. Edit config.yaml as needed
3. run `rake migrate_dasblog`
