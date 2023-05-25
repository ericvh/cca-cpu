#!/bbin/elvish

var ns = [ "/workspaces" "/home" "/lib" "/usr" "/bin" "/etc" ]

mount -t 9p -o trans=virtio,protocol=9p2000.L FM /mnt

echo "Mounting namespace from host...."
for p $ns {
    mkdir -p $p
    mount -t none -o bind /mnt$p $p
}

if ( > (count $args) 0 ) {  
    elvish -c $@args
} else {
    echo starting Realm....be patient
    /usr/local/share/cca/lkvm-cca
}