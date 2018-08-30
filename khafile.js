let project = new Project('Armory2D');

project.addSources('Sources');
project.addAssets('Assets/**');
project.addLibrary('zui');

await project.addProject('Libraries/yui');
// project.addLibrary('yui');
// project.addLibrary('tink_json');

resolve(project);
