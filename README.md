
## TagPix

Here's a half-baked idea I had while working on a couple of projects using NFC tags. It's a detour
from a detour ...

Anyway, something appeals to me about the idea of exchanging images via NFC tags. I don't quite know
where to go with this, but here's a start for when inspiration strikes and I get back to it.

The tags I have are NTAG215 which, according to [NFC Tools](https://apps.apple.com/us/app/nfc-tools/id1252962749) can only hold 540 bytes (_everything I've seen online
says [504](https://www.nxp.com/products/rfid-nfc/nfc-hf/ntag-for-tags-and-labels/ntag-213-215-216-nfc-forum-type-2-tag-compliant-ic-with-144-504-888-bytes-user-memory:NTAG213_215_216#:~:text=NTAG%20213%2C%20NTAG%20215%2C%20and,NFC%2Dcompliant%20Proximity%20Coupling%20Devices.)_ 🤷), so it presents a little bit of a challenge: I created a 16x16 PNG file and it was 
1.3K. I used [ImageMagick](https://imagemagick.org/) to convert to several other formats with the following results:

Format | Size
------ | ----
BMP | 3.1k
Farbfeld | 2k
GIF | 2k
JPG | 2.5k




Perhaps if I played around with various options I could do better.

For now, I've opted for a fixed pallette and am just storing the color index of each pixel as a UInt8.
Since my pallette has only 16 entries, I could pack the info into a nybble. Maybe later.  As it is,
this allows me to store a 16x16 image in 257 bytes (_one byte for image size, in case I don't want to stick with just 16x16_)&mdash;which easily fits on the tag.

Originally I intended to implement simple paint functionality, but decided I'd rather get back to my actual project. Let me know if 
you have interesting ideas on where to go with this; just create an [issue](https://github.com/profburke/tagpix/issues).