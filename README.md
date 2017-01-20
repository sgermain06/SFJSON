# Parse JSON using paths!

### This sucks

```swift
do {
	let jsonData = try Data(contentsOfURL: URL(string: url)!)
	let json = try JSONSerialization.JSONObject(jsonData, options: [])

	if let json = jsonOptional as? [String: Any] {
    	if let other = json["other"] as? [String: Any] {
        	if let nicknames = other["nicknames"] as? [String] {
            	if let handle = nicknames[0] as? String {
                	print("Some folks call me \(handle)")
                }
            }
        }
    }
}
catch {
	print("Dangit, what happened here? \(error.localizedDescription)")
}
```

### This rocks

```swift
do {
    let jsonData = try Data(contentsOfURL: URL(string: url)!)
    let parser = try JSONParser(data: jsonData)

	if let handle = try parser.getString("other.nicknames[0]") {
        print("Some folks call me \(handle)")
    }
}
catch {
    print("Dangit! Another error! \(error.localizedDescription)")
}
```

### Your JSON is already parsed? No problem!
```swift
let parser = JSONParser(dictionary: existingDictionary)

if let handle = try parser.getString("other.nicknames[0]") {
	print("Some folks like to call me \(handle)")
}
```

## Usage

Sample JSON payload we want to parse

    {
        "name": "Mike",
        "favorite_number": 19,
        "gpa": 2.6,
        "favorite_things": ["Github", 42, 98.6],
        "other": {
            "city": "San Francisco",
            "commit_count": 9000,
            "nicknames": ["mrap", "Mikee"]
        }
    }

Get values of a specific type. Returns optionals

```swift
if let name = try parser.getString("name") {
    print("My name is \(name)")
}

if let number = try parser.getInt("favorite_number") {
    print("\(number) is my favorite number!")
}

if let gpa = try parser.getDouble("gpa") {
    print("My stellar highschool gpa was \(gpa)")
}
```

Or get `Any` if you're not sure

```swift
if let city = parser.get("other.city") {
    // city will be type Any
}
```

Get an Array of values

```swift
if let favorites = parser.getArray("favorite_things") {
    // favorites => ["Github", 42, 98.6]
}
```

## Error Handling

Using the new Swift `try/catch` blocks, handling errors has never been easier!

```swift
do {
    let badJsonData = try Data(contentsOfURL: URL(string: url)!)
    let parser = try JSONParser(data: badJsonData)
    // Everything was fine past this point! Rock on!!
}
catch {
	// Dangit! One more error... *sigh*
	print("Some error happened! Fix it! Here it is: \(error.localizedDescription)")
}
```

## Installation
The best way to use SFJSON is to use CocoaPods

1. Open your `Podfile` and add `pod 'SFJSON'` under your `target` section.
- Make sure that `use_frameworks!` is present.
- Run `pod install` to have Cocoapods download the pod and install it in your project.
- Make sure you compile your project once after installing the pod for the project to have a reference to `SFJSON`
- Add `import SFJSON` to your Swift class and start using `SFJSON`!

## Disclaimer
This framework is not my original idea. The original idea belongs to Mike Rapadas (https://github.com/mrap), which I would like to thank very much. His framework is sensibly the same as this, except his was written using the first version of Swift. I simply refreshed it and adapted it for Swift 3, which is much more current.