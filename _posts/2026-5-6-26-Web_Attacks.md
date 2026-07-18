---
title: HackTheBox Web Attacks (Skills Assessment)
date: 2026-05-26 12:00:00 +0300
categories: [HackTheBox Skills Assessment , Web Penetration Tester Path]
tags: [HTB Web Assessment , IDOR , XXE , XML , SOAP API , Verb Tampering , FFUF ]
---
**Hello World**

Today, I will solve the Web Attacks Skills Assessment in the HackTheBox Web Penetration Tester Path .

![Image]({{ '/assets/img/web_attacks/image_1.png' | relative_url }})


## Reconnaissance

First, let’s use the IP address provided to access the web application through the browser and find the login page.

![Image]({{ '/assets/img/web_attacks/image_2.png' | relative_url }})

Let’s run Burp to capture requests in the HTTP history.

We can use the credentials provided to log in:

‘htb-student: Academy_student!’

When we logged in, we could see this request in the HTTP history. Let’s send it to Repeater to inspect it.

![Image]({{ '/assets/img/web_attacks/image_3.png' | relative_url }})

When we change the uid header, nothing happens.

So let’s try changing the user ID in the first line of the request. Indeed, another user’s data appears in the response.

![Image]({{ '/assets/img/web_attacks/image_4.png' | relative_url }})

## IDOR Attack

So we need to send this request to Intruder to brute-force the admin ID.

First, we must specify the ID, then go to the Payloads section and set these options:

![Image]({{ '/assets/img/web_attacks/image_5.png' | relative_url }})

Second, we must add a marker to identify the admin ID. Let’s go to the settings, clear the “Grep — Match” section, and replace it with the word ‘admin’, since we are looking for the admin account.

![Image]({{ '/assets/img/web_attacks/image_6.png' | relative_url }})

Then let’s start brute-forcing.

We found this response.

![Image]({{ '/assets/img/web_attacks/image_7.png' | relative_url }})

Now we have the admin’s ID and username.

When we explore the page a bit, we find the settings section, which contains a function to change the password. Let’s test it.

![Image]({{ '/assets/img/web_attacks/image_8.png' | relative_url }})

Let’s try changing our password and inspect the request content.

In the HTTP history, we will notice two requests: one contains the user token.

![Image]({{ '/assets/img/web_attacks/image_9.png' | relative_url }})

And the other changes the password.

![Image]({{ '/assets/img/web_attacks/image_10.png' | relative_url }})

After a few checks, we will notice that this request identifies users using the “uid” and “token”.

So let’s try to obtain the admin account token from the first request. We will send it to Repeater and change the ID in the first line of the request, as we did before, to the admin account ID.

![Image]({{ '/assets/img/web_attacks/image_11.png' | relative_url }})

Now we have the admin token and username.

So let’s try to change the admin password using this data and the second request.

Let’s send a reset request to Repeater and change the token and uid headers to the admin values to see the response.

![Image]({{ '/assets/img/web_attacks/image_12.png' | relative_url }})

To overcome this issue, we must change the request method from POST to GET.

We succeeded.

![Image]({{ '/assets/img/web_attacks/image_13.png' | relative_url }})

Now we have the admin username and password: ‘a.corrales:nour’.

So let’s log in to the admin account.

![Image]({{ '/assets/img/web_attacks/image_14.png' | relative_url }})

Now we can add events. Let’s try adding one.

![Image]({{ '/assets/img/web_attacks/image_15.png' | relative_url }})

In the HTTP history, we will find that the event is created using XML. Let’s look for the entity that is reflected in the response and try to inject an XML payload to see whether it is vulnerable.

![Image]({{ '/assets/img/web_attacks/image_16.png' | relative_url }})

The ‘name’ entity is reflected.

So let’s insert an XML payload to read the ‘passwd’ file.

![Image]({{ '/assets/img/web_attacks/image_17.png' | relative_url }})

## XXE Attack

And we succeeded. Let’s try to retrieve the flag from the ‘/flag.php’ directory.

![Image]({{ '/assets/img/web_attacks/image_18.png' | relative_url }})

The contents of the file did not appear, so let’s use PHP filters.

![Image]({{ '/assets/img/web_attacks/image_19.png' | relative_url }})

Now we have the flag in Base64 format. Let’s send it to a decoder to decode it.

![Image]({{ '/assets/img/web_attacks/image_20.png' | relative_url }})

And we got the flag. :)

![Image]({{ '/assets/img/web_attacks/image_21.gif' | relative_url }})

## Conclusion

If you find it helpful, ***Kindly*** give me *respect* from here [N0UR0X01-HTB](https://app.hackthebox.com/users/840216)

#### Stay in touch

**[LinkedIn](https://www.linkedin.com/in/n0ur0x01)** |
**[Twitter](https://x.com/N0UR0X01)**
