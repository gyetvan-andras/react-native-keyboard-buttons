'use strict';

const React = require('react');

const {findNodeHandle, TextInput, NativeAppEventEmitter, NativeModules: {
	KeyboardToolbar
}, processColor} = require('react-native');

class RCTKeyboardToolbarHelper {
	constructor() {
		this.counter = 0;
		this.callbackList = {};
	}
	getUid() {
		return _RCTKeyboardToolbarHelper.counter++;
	}
	setCallback(key, value) {
		_RCTKeyboardToolbarHelper.callbackList[key] = value;
	}
	getCallback(key) {
		return _RCTKeyboardToolbarHelper.callbackList[key];
	}
	clearCallback(key) {
		delete _RCTKeyboardToolbarHelper.callbackList[key];
	}
}

const _RCTKeyboardToolbarHelper = new RCTKeyboardToolbarHelper()

NativeAppEventEmitter.addListener('TUKeyboardToolbarDidTouchOn', (data) => {
	console.log(data)
	let eventHandler = _RCTKeyboardToolbarHelper.getCallback(data.uid).onAction;
	if (eventHandler) {
		eventHandler(data.button);
	}
});

class RCTKeyboardToolbarManager {
	configure(node, options, callbacks) {
		var reactNode = findNodeHandle(node);
		options.uid = _RCTKeyboardToolbarHelper.getUid();
		KeyboardToolbar.configure(reactNode, options, (error, currentUid) => {
			node.uid = currentUid;
			if (!error) {
				_RCTKeyboardToolbarHelper.setCallback(currentUid, {
					onAction: callbacks.onAction
				});
			}
		});
	}
}

const _RCTKeyboardToolbarManager = new RCTKeyboardToolbarManager()

class TextInputWithButtons extends React.Component {
	componentDidMount() {
		var callbacks = {
			onAction: (button) => {
				if (this.props.onAction) {
					this.props.onAction(button);
				}
			}
		};

		_RCTKeyboardToolbarManager.configure(this.refs.input, {
			barStyle: this.props.barStyle,
			buttons: this.props.buttons,
		}, callbacks);
	}

	componentWillUnmount() {
		_RCTKeyboardToolbarHelper.clearCallback(this.refs.input.uid);
	}

	focus() {
		this.refs.input.focus();
	}
	render() {
		return (<TextInput {...this.props} ref="input" />);
	}
}

module.exports = TextInputWithButtons;