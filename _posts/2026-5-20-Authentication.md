---
title: HackTheBox Broken Authentication (Skills Assessment)
date: 2026-05-20 12:00:00 +0300
categories: [HackTheBox Skills Assessment , Web Penetration Tester Path ]
tags: [HTB Web Assessment , Broken_Authentication , Web , verb Tempring , FFUF]
---

**Hello World**

Today, I will solve the Broken Authentication Skills Assessment in the HackTheBox Web Penetration Tester Path.

![Image]({{ '/assets/img/authentication/image_1.png' | relative_url }})
*Type caption for image (optional)*


## Reconnaissance

First, I used the IP address provided to access the web application through the browser.

![Image]({{ '/assets/img/authentication/image_2.png' | relative_url }})
*Type caption for image (optional)*

There is a login page, so let’s go to it and test it.

![Image]({{ '/assets/img/authentication/image_3.png' | relative_url }})
*Type caption for image (optional)*

I entered some incorrect credentials, such as nour:nour, to see the response. The application replied with:

“Unknown username or password”

![Image]({{ '/assets/img/authentication/image_4.png' | relative_url }})
*Type caption for image (optional)*

So, let’s go to “Register a new account” and create an account.

![Image]({{ '/assets/img/authentication/image_5.png' | relative_url }})
*Type caption for image (optional)*

I tried to create an account with these credentials, nour:nour, but the web application prevented me and showed me this policy.

![Image]({{ '/assets/img/authentication/image_6.png' | relative_url }})
*Type caption for image (optional)*

So I created an account with the credentials “nour:N0uR56789123”, and I succeeded in creating it.

![Image]({{ '/assets/img/authentication/image_7.png' | relative_url }})
*Type caption for image (optional)*

Then I went to the login page again and tried to log in with my new account. I got this response:

![Image]({{ '/assets/img/authentication/image_8.png' | relative_url }})
*Type caption for image (optional)*

Let’s go back to the login page and try entering the wrong password with the same username, such as “nour:LoL456789123”. I got a different error.

![Image]({{ '/assets/img/authentication/image_9.png' | relative_url }})
*Type caption for image (optional)*

So I noted the following:

When I try to log in with a non-existent username, I get this error message: “Unknown username or password”.

And when I try to log in with an existing username but the wrong password, I get this error: “Invalid credentials”.

![Image]({{ '/assets/img/authentication/image_10.png' | relative_url }})
*Type caption for image (optional)*

## Username Enumeration

Now I can brute-force this form to retrieve some usernames.

Let’s use ffuf with [xato-net-10-million-usernames.txt](https://github.com/danielmiessler/SecLists/blame/master/Usernames/xato-net-10-million-usernames.txt) from [SecLists](https://github.com/danielmiessler/SecLists) to brute-force usernames. First, we need the “Content-Type” and “PHPSESSID” headers for ffuf, because we are brute-forcing a PHP form and can obtain them by intercepting a login request in Burp.

![Image]({{ '/assets/img/authentication/image_11.png' | relative_url }})
*Type caption for image (optional)*

```json
Content-Type: application/x-www-form-urlencoded
PHPSESSID=omnsv4jmtrvj05ur7qkhhqio3e
```

Now let’s brute-force with ffuf.

```shell
ffuf -u http://83.136.249.29:45638/login.php -w /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt -H "Content-Type: application/x-www-form-urlencoded" -b "PHPSESSID=omnsv4jmtrvj05ur7qkhhqio3e" -d "username=FUZZ&password=N0uR56789123" -fr "Unknown username or password"Auto (undefined)
```

- u: To set the target URL
- -w: To set the wordlist
- -H: To set the header
- -b: To set the ‘PHPSESSID’ header
- -d: To set the POST parameters
- -fr: To hide responses that contain the message “Unknown username or password”

![Image]({{ '/assets/img/authentication/image_12.png' | relative_url }})
*Type caption for image (optional)*

And we got a username: ‘gladys’.

Now that we have a username but no password, we will use rockyou.txt. We should remember the password policy we saw when we created our account.

```text
Contains at least one digit
Contains at least one lowercase character
Contains at least one uppercase character
Contains no special characters
Is exactly 12 characters long
```

Now we need to narrow the search to extract passwords that meet these policies from rockyou.txt and create a new wordlist.

So I used this command to generate a new wordlist called ‘password.txt’

```shell
grep -P '^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])[a-zA-Z0-9]{12}$' rockyou.txt > password.txt
```

![Image]({{ '/assets/img/authentication/image_13.png' | relative_url }})
*Type caption for image (optional)*

## Password Attack

Now we can brute-force the password using the same ffuf command, changing the -b flag and editing the username and password to “username=gladys&password=FUZZ”. We also change the wordlist to ‘password.txt’ and the -fr flag to “Invalid credentials”, because now we have a username and are brute-forcing the password. If the password is wrong, we will see the error message “Invalid credentials”.

```shell
ffuf -u http://83.136.249.29:45638/login.php -w /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt -H "Content-Type: application/x-www-form-urlencoded" -b "PHPSESSID=omnsv4jmtrvj05ur7qkhhqio3e" -d "username=gladys&password=FUZZ" -fr "Invalid credentials"
```

![Image]({{ '/assets/img/authentication/image_14.png' | relative_url }})
*Type caption for image (optional)*

And we get the password.

Let’s log in to this account using these credentials.

![Image]({{ '/assets/img/authentication/image_15.png' | relative_url }})
*Type caption for image (optional)*

We have a 2FA page, and I tried to generate a wordlist from 0000 to 9999, but it did not work.

NOTE: To generate a wordlist for brute-forcing OTPs, use this command:

```shell
seq -w 0 9999 > otp.txt
```

So I tried a force-browsing technique.

We know that the web application redirects us to ‘/profile.php’ after login.

So, by simply changing the directory from ‘[http://83.136.254.47:57509/2fa.php](http://83.136.254.47:57509/2fa.php)’ to ‘[http://83.136.254.47:57509](http://83.136.254.47:57509/2fa.php)/profile.php’, I got this error.

![Image]({{ '/assets/img/authentication/image_16.png' | relative_url }})
*Type caption for image (optional)*

## Two-Factor Bypass

So let’s use Burp Repeater to understand what happened.

First, we must intercept the request when we try to access ‘/profile.php’ and send it to Repeater.

![Image]({{ '/assets/img/authentication/image_17.png' | relative_url }})
*Type caption for image (optional)*

And we get the flag in Repeater. Let’s now try to access this directory in our browser.

To access it, we must intercept the request and then intercept the response, and then click Forward.

![Image]({{ '/assets/img/authentication/image_18.png' | relative_url }})
*Type caption for image (optional)*

Now we intercept the response and get the same result in Repeater.

![Image]({{ '/assets/img/authentication/image_19.png' | relative_url }})
*Type caption for image (optional)*

Now let’s change the status code from 302 to 200 and click Forward.

![Image]({{ '/assets/img/authentication/image_20.png' | relative_url }})
*Type caption for image (optional)*

And we got the flag. :)

## Root Cause

What happened?

Why can’t we access ‘/profile.php’ from the beginning?

The answer is that the developer forgot to add an ‘exit’ after the code that prevents us from accessing other directories without the OTP.

This code redirects the user to '`/2fa.php'` if the session is not active:

```php
if(!$_SESSION['active']) {
    header("Location: 2fa.php");
}
```

To prevent the protected information from being returned in the body of the redirect response, the PHP script needs to exit after issuing the redirect:

```php
if(!$_SESSION['active']) {
    header("Location: 2fa.php");
    exit;
}
```

![Image]({{ '/assets/img/authentication/image_21.gif' | relative_url }})
*Type caption for image (optional)*

If you find it helpful, ***Kindly*** give me *respect* from here [N0UR0X01-HTB](https://app.hackthebox.com/users/840216)

#### Stay in touch

**[LinkedIn](https://www.linkedin.com/in/n0ur0x01)** |
**[Twitter](https://x.com/N0UR0X01)**

