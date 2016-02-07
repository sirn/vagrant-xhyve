require 'mkmf'

$libs += "-framework vmnet"
extension_name = 'vmnet_mac'
create_makefile(extension_name)
