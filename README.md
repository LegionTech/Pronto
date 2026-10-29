# Monopoly-style Ruby Game

This project is a small Ruby implementation of a Monopoly-like board game. It reads player data and roll data from JSON files, updates player positions and balances, buys properties, and applies rent payments.

## Prerequisites

- Ruby 3.x or newer
- A terminal or command prompt
- Optional: a Ruby code editor such as VS Code

No external gems are required for the core program because the project uses Ruby’s built-in `json` library.

## Install dependencies

The project uses only the Ruby standard library, so there are no external package installs required.

To verify Ruby is installed:

```bash ruby -v ```

## How to Run
Navigate to Pronto/ProntoRuby folder, and run the following command in your terminal:
```ruby Program.rb board.json rolls_1.json --json```

## Design Decisions
- I used object-oriented programming and created Player and Property classes.
- Broke down the business flow into separate functions such as dice-roll, move, pay rent, and make a purchase.

## Assumption
- Player is bankrupted when their balance is negativie after paying a rent or purchasing a property.

## Outputs
- rolls_1.json:
{
  "winners": "Peter",
  "players": [
    {
      "name": "Peter",
      "money": 40,
      "space": "Lanzhou Beef Noodle"
    },
    {
      "name": "Billy",
      "money": 9,
      "space": "Gami Chicken"
    },
    {
      "name": "Charlotte",
      "money": 6,
      "space": "Betty's Burgers"
    },
    {
      "name": "Sweedal",
      "money": 6,
      "space": "Gami Chicken"
    }
  ]
}

- rolls_2.json:
{
  "winners": "Billy",
  "players": [
    {
      "name": "Peter",
      "money": 10,
      "space": "Fast Kebabs"
    },
    {
      "name": "Billy",
      "money": 35,
      "space": "Gami Chicken"
    },
    {
      "name": "Charlotte",
      "money": 27,
      "space": "Fast Kebabs"
    },
    {
      "name": "Sweedal",
      "money": 8,
      "space": "Fast Kebabs"
    }
  ]
}

## Additional
- I use Ruby 3.2.3 on Linux.
- I added a rolls_3.json file to test each player owning properties of colours, for example Charlotte has both Green properties. The two rolls leave the last 2 players unable to purchase a property.