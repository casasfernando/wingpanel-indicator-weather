# Project name, programming language and version
project (
    'com.github.casasfernando.wingpanel-indicator-weather',
    'c', 'vala',
    version: '0.7.3'
)

# GNOME module
gnome = import ('gnome')

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: 'c'
)

add_project_arguments (
    ['--vapidir', join_paths (meson.current_source_dir (), 'vapi')],
    language: 'vala'
)

# Listing dependencies
wingpanel = dependency ('wingpanel')

dependencies = [
    dependency ('granite'),
    dependency ('gtk+-3.0'),
    dependency ('gee-0.8'),
    dependency ('glib-2.0'),
    dependency ('libgeoclue-2.0'),
    dependency ('gweather-3.0'),
    dependency ('gdk-x11-3.0'),
    dependency ('libnotify'),
    dependency ('libhandy-1'),
    wingpanel,
    meson.get_compiler ('c').find_library ('m', required : false),
    meson.get_compiler ('vala').find_library ('posix')
]

# Compiling resources
asresources = gnome.compile_resources (
    'as-resources',
    join_paths ('data', meson.project_name ()) + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

# Config
config_data = configuration_data ()
config_data.set_quoted ('GETTEXT_PACKAGE', meson.project_name ())

configure_file (output: 'config.h', configuration: config_data)

c_args = [
  '-DGWEATHER_I_KNOW_THIS_IS_UNSTABLE',
  '-include', 'config.h',
  '-w',
]

subdir ('src')

# Define indicator
shared_module (
    meson.project_name (),
    sources,
    asresources,
    c_args: c_args,
    dependencies: dependencies,
    install: true,
    install_dir : wingpanel.get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', join_paths (get_option ('prefix'), get_option ('libdir'))]),
)


subdir ('data')
subdir ('po')

meson.add_install_script ('meson/post_install.py')
