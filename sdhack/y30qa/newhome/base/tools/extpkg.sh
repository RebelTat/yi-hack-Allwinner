echo "------------------------------------home base tools extpkg.sh enter------------------------------------"
cd /tmp/update
cp -rf $1 /tmp/update/home_y30qam

# hack
# test if bz2 file and jump directly to decompression function

dd if=home_y30qam of=header bs=2 count=1
HEADER=`hexdump -n 2 -x header | grep 0000000 | awk '{print $2}'`
if [ "$HEADER" == "5a42" ]; then
    SWAP=`cat /proc/meminfo | grep SwapTotal | awk '{print $2}'`
    if [[ "$SWAP" == "0" ]]; then
        SD_PRESENT=$(mount | grep mmc | grep -c ^)
        if [[ $SD_PRESENT -eq 1 ]]; then
            rm /tmp/sd/swapfile_update
            dd if=/dev/zero of=/tmp/sd/swapfile_update bs=1M count=64
            chmod 0600 /tmp/sd/swapfile_update
            mkswap /tmp/sd/swapfile_update
            swapon /tmp/sd/swapfile_update
        fi
    fi
    mv home_y30qam home4
else
    cp /home/base/tools/rsa_pub_dec /home/base/tools/7za /tmp/update

    dd if=home_y30qam of=verout bs=22 count=1
    dd if=home_y30qam of=home1 bs=22 skip=1 count=999999999999999
    rm home_y30qam
    dd if=home1 of=enc_key bs=1024 count=1
    dd if=home1 of=home2 bs=1024 skip=1 count=99999999999999
    rm home1

    /tmp/update/rsa_pub_dec enc_key dec_enc_key
    act=$?
    base=0
    if [ $act -eq $base ]
    then
        echo rsa_pub_dec return pass
    else
        echo rsa_pub_dec return fail
        sync
        exit
    fi

    cat dec_enc_key home2 > home3
    rm home2
    dd if=home3 of=home4 bs=66 skip=1 count=99999999
    dd if=home3 of=md5 bs=33 count=1
    dd if=home3 of=pwd bs=33 skip=1 count=1
    dd if=home4 of=verin bs=22 count=1


    echo "md5:"
    cat md5
    echo "pwd:"
    cat pwd
    echo "ver_in:"
    cat verin
    rm home3
    dd if=home4 of=home_y30qam.7z bs=22 skip=1 count=9999999999999
    rm home4
    mv home_y30qam.7z home4
    zpwd=$(cat pwd)
    ver_out=$(cat verout)
    ver_in=$(cat verin)
    if [ -f /home/homever ]; then
        oldver=$(cat /home/homever)
    else
        oldver=0
    fi

    echo ver_in=$ver_in, ver_out=$ver_out
    if [ $ver_in != $ver_out ];then
        echo ver_in!=ver_out, check fail
        #rm $1
        sync
        exit
    else
        echo ver_in==ver_out, check pass
    fi

    echo ver_in=$ver_in, oldver=$oldver
    if [ $ver_in != $oldver ];then
        echo ver_in!=oldver, check pass
    else
        echo ver_in==oldver, check fail
        #rm /tmp/sd/home_y30m
        sync
        exit
    fi

    md5_home4=$(md5sum home4 | awk  '{print $1}')
    md5_in=$(cat md5)
    if [ $md5_home4 != $md5_in ];then
        echo md5_home4!=md5_in, check fail
        sync
        exit
    else
        echo md5_home4==md5_in, check pass
    fi
fi
#./7za x home4 -p$zpwd
tar -jxvf home4
/tmp/update/home/app/script/update.sh
cd -
echo "------------------------------------home base tools extpkg.sh exit------------------------------------"
