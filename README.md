## React Native Keyboard Buttons (iOS only)

This package provides custom buttons added above the system keyboard. The code is based on [react-native-textinput-utils](https://github.com/DickyT/react-native-textinput-utils)

## Installation

```
npm i --save https://github.com/gyetvan-andras/react-native-keyboard-buttons
react-native link
```
If you would like to use **< >** images in your keyboard toolbar buttons, copy the content of Images folder to your XCode project.

## Usage

```<TextInputWithButtons>``` is a ```<TextInput>``` replacement and it is fully compatible with it. The following properties should be provided:

1. buttons: an array of button description which is the following:
```javascript
{
	title: string,
	color: React Native compatible color string,
	key:string 
}
```
	- The title is parsed as follows:
		- < - replaced with a back image
		- \> - replaced with a forward image
		- | - replaced with a felxibile space
		- Done - will bolded

	- If no key provided then the title will be used. Also, when no color provided it will be replaced with the default blue iOS toolbar color.
	
2. onAction: called when a button pressed, the key parameter is passed.

```javascript
<TextInputWithButtons style={[styles.text_input, { flex: 0, width: 40, alignSelf: 'center' }]}
	buttons={[
		{
			title:'<',
			color:'#00ff00',
			key:'back'
		},
		{
			title:'>',
			key:'prev'
		},
		{
			title:'|',
		},
		{
			title:'Done',
			key:'done'
		},
	]}
	onAction={(button) => console.log('Keyboard button selected:',button)}
	keyboardType={'numeric'}
	selectTextOnFocus={true}
	onChangeText={(text) => {
		this.props.field.value = text
	}}
	value={this.props.field.value}
/>
```

The above code will create the following keyboard
<p align="center">
<img src="docs/sample.png"/> 
</p>