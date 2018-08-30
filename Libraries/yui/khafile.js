let prj = new Project('yui');

prj.addAssets('plugin/**');

prj.addLibrary('haxe-format-bmfont');
prj.addLibrary('spriter');
prj.addLibrary('tink_json');

prj.addSources('src');
resolve(prj);
