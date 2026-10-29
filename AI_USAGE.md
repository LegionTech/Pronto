## Which tools you used, and what you used each one for
GitHub Copilot: 
- Initial code generation for reference and inspiration.
- Converted my own C# based codes to Ruby.
- Code suggestions and auto-completion while merging both versions.

## At least two places where a tool was wrong, unhelpful or over-complicated things, how you noticed, and what you did about it

- Condition if for a class object isn't valid in Copilot-suggested Ruby codes.

- The C#-to-Ruby translation is not 100% correct, for example C# list became an array on Ruby, as the object retrival is of array instead of list on Ruby. I had to fix it.

- The class object initialization and mapping from JSON wasn't right, and I had to fix it.

## Something you decided to write or rewrite yourself, and why
- I moved both Players and Properties to be global variables, so the data could be read and updated on every function.
