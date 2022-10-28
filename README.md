# Jarkom-Modul-2-ITB03-2022
---
Kelompok ITB03:
1. Haffif Rasya Fauzi - 5027201002
2. M. Hilmi Azis - 5027201049
3. Gennaro Fajar Mende - 5027201061
---

## Soal 1
WISE akan dijadikan sebagai DNS Master, Berlint akan dijadikan DNS Slave, dan Eden akan digunakan sebagai Web Server. Terdapat 2 Client yaitu SSS, dan Garden. Semua node terhubung pada router Ostania, sehingga dapat mengakses internet

### Jawab soal 1
Kami telah membuat topologi terlebih dahulu. untuk topologi yaitu sebagai berikut:

![](gambar/1.png)

Lalu, disini kami akan melakukan konfigurasi pada setiap node.

Ostania sebagai router

![](gambar/2.png)

WISE sebagai DNS Server

![](gambar/3.png)

Berlint sebagai DNS Slave

![](gambar/4.png)

Eden sebagai Web Server

![](gambar/5.png)

SSS sebagai Client

![](gambar/6.png)

Garden sebagai Client

![](gambar/7.png)

Kemudian setiap node diaktifkan dengan mengklik tombol start. Setelah itu, menjalankan command `iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.46.0.0/16` pada router Ostania upaya dapat terkoneksi dengan internet.


## Soal 2
Untuk mempermudah mendapatkan informasi mengenai misi dari Handler, bantulah Loid membuat website utama dengan akses wise.yyy.com dengan alias www.wise.yyy.com pada folder wise

### Jawab soal 2
``Server WISE``

Melakukan konfigurasi terhadap file /etc/bind/named.conf.local dengan menambahkan sebagai berikut:

```
zone "wise.itb03.com" {
        type master;
        file "/etc/bind/wise/wise.itb03.com";
};
```

kemudian, kami membuat direktori baru yaitu wise dengan command:
`mkdir -p /etc/bind/wise`

Lalu, menambahkan konfigurasi pada `/etc/bind/wise/wise.itb03.com` dengan sebagai berikut:
```
$TTL    604800
@       IN      SOA     wise.itb03.com. root.wise.itb03.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@             IN      NS      wise.itb03.com.
@             IN      A       10.46.2.2 ; IP WISE
@             IN      AAAA    ::1
www           IN      CNAME   wise.itb03.com.
```

Melakukan restart service bind9 dengan service bind9 restart

``Server Berlint``

```
apt-get update  
apt-get install dnsutils -y  
echo "nameserver 10.46.2.2" > /etc/resolv.conf 
``` 

####Testing
