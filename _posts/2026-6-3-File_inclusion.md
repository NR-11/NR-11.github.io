---
title: HackTheBox File Inclusion (Skills Assessment)
date: 2026-06-03 12:00:00 +0300
categories: [HackTheBox Skills Assessment , Web Penetration Tester Path]
tags: [HTB Assessment , File Inclusion , lfi , RCE , Log Poisoning]
---
**Hello World**

Today, I will solve the File Inclusion Skills Assessment in the HackTheBox Web Penetration Tester Path.

![Image]({{ '/assets/img/file_inclusion/image_1.png' | relative_url }})

## Reconnaissance

First, I used the IP address provided to access the web application through the browser.

There is a site that provides World Wide Freight services.

![Image]({{ '/assets/img/file_inclusion/image_2.png' | relative_url }})

Then I started browsing the site and found a parameter called “page”.

![Image]({{ '/assets/img/file_inclusion/image_3.png' | relative_url }})

So I went to Burp, took this request to Repeater, and started testing the LFI vulnerability, but it did not work.

So I tried using PHP wrappers to display the contents of the files, and it worked.

```php
php://filter/read=convert.base64-encode/resource=contact
```

![Image]({{ '/assets/img/file_inclusion/image_4.png' | relative_url }})

So I decoded it and found that its content was not useful, so I decided to fuzz the PHP files using ffuf.

```shell
ffuf -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-small.txt:FUZZ -u http://94.237.48.253:38964/FUZZ.php -ic
```

![Image]({{ '/assets/img/file_inclusion/image_5.png' | relative_url }})

So I tried using PHP wrappers with the index file.

![Image]({{ '/assets/img/file_inclusion/image_6.png' | relative_url }})

Then I decoded it and found this.

![Image]({{ '/assets/img/file_inclusion/image_7.png' | relative_url }})

This indicates that there is a hidden admin panel, and it displays some logs.

![Image]({{ '/assets/img/file_inclusion/image_8.png' | relative_url }})

I also noticed that there is another parameter that specifies the type of logs displayed. So I tried using LFI payloads, and it worked.

![Image]({{ '/assets/img/file_inclusion/image_9.png' | relative_url }})

## Log Poisoning

Then I tried to access the file that contains the web application’s logs by fuzzing these files to reach the correct path.

```shell
ffuf -w LFI-gracefulsecurity-linux.txt:FUZZ -u http://94.237.48.253:38964/ilf_admin/index.php?log=../../../../../../../FUZZ -fs 2046
```

and I found the ‘access.log’ file.

![Image]({{ '/assets/img/file_inclusion/image_10.png' | relative_url }})

Then I displayed its content directly on the page using the “log” parameter.

![Image]({{ '/assets/img/file_inclusion/image_11.png' | relative_url }})

I noticed that it was storing the user-agent header, so I tried log poisoning, and it worked.

![Image]({{ '/assets/img/file_inclusion/image_12.png' | relative_url }})

And now we got our flag.

![Image]({{ '/assets/img/file_inclusion/image_13.png' | relative_url }})

![Image]({{ '/assets/img/file_inclusion/image_14.gif' | relative_url }})

## Conclusion

If you find it helpful, ***Kindly*** give me *respect* from here [N0UR0X01-HTB](https://app.hackthebox.com/users/840216)

#### Stay in touch

**[LinkedIn](https://www.linkedin.com/in/n0ur0x01)** |
**[Twitter](https://x.com/N0UR0X01)**

