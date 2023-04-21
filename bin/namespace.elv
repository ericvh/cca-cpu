#!/bbin/elvish

var ns = [ "/workspaces" "/home" "/lib" "/usr" "/bin" "/etc" ]

mount -t 9p -o trans=virtio,protocol=9p2000.L FM /mnt

for p $ns {
    mkdir -p $p
    mount -t none -o bind /mnt$p $p
}

if ( > (count $args) 0 ) {  
    elvish -c $@args
} else {
    /bin/bash
}