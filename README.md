# Sahada waitlist

Single static page (`index.html`) that writes signups to Supabase through two RPCs:
`join_launch_waitlist(p_contact, p_sport, p_ref, p_lang)` and `launch_waitlist_count()`.
The table itself is not readable or writable with the public key.

Live: https://heshamrahwanji.github.io/sahada-waitlist/

## Deploy
Hosted on GitHub Pages from the `gh-pages` branch — push to it and the site updates in about a minute.

Custom domain (e.g. `sahada.app` or `katil.sahada.app`):
1. Add a file named `CNAME` containing the domain, push it.
2. At your DNS provider: for a subdomain add `CNAME → heshamrahwanji.github.io`;
   for the apex add A records 185.199.108.153, .109.153, .110.153, .111.153.
3. Repo → Settings → Pages → tick "Enforce HTTPS" once the certificate is issued.
4. Update the `og:image` URL in `index.html` to the new domain.

## Config (top of the script in index.html)
- `COUNTER_MIN` — below this many signups the counter reads "Be one of the first players".
- Instagram link: the `#ig` anchor in the footer.
