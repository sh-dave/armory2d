package;

typedef TicTacToeState = {
	cells: Array<String>,
	activePlayer: String,
	gameOver: Null<GameOver>,
}

enum GameOver {
	Draw;
	Winner( player: String );
}

typedef TicTacToeOpts = {
	onStateChanged: TicTacToeState -> Void,
	onGameOver: GameOver -> Void,
}

class TicTacToe {
	var state: TicTacToeState;
	var onStateChanged: TicTacToeState -> Void;
	var onGameOver: GameOver -> Void;

	public function new( opts: TicTacToeOpts ) {
		this.onStateChanged = opts.onStateChanged;
		this.onGameOver = opts.onGameOver;

		newGame();
	}

	public function newGame() {
		state = {
			cells: [null, null, null, null, null, null, null, null, null],
			activePlayer: 'x',
			gameOver: null,
		}

		onStateChanged(state);
	}

	public function clickFieldIndex( index: Int ) {
		switch state.cells[index] {
			case null:
				if (state.gameOver != null) {
					return;
				}

				state.cells[index] = state.activePlayer;

				var gameOver = isVictory(state.cells)
					? Winner(state.activePlayer)
					: isDraw(state.cells)
						? Draw
						: null;

				state.activePlayer = switch state.activePlayer {
					case 'x': 'o';
					case 'o': 'x';
					case invalid: invalid;
				}

				onStateChanged(state);

				if (gameOver != null) {
					onGameOver(state.gameOver = gameOver);
				}
			case invalid:
		}
	}

	static var victoryPositions = [
		[0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
		[0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
		[0, 4, 8], [2, 4, 6], // diagonal
	];

	static function isVictory( cells: Array<String> ) : Bool {
		for (pos in victoryPositions) {
			var symbol = cells[pos[0]];
			var winner = symbol;

			for (i in 0...pos.length) {
				if (cells[pos[i]] != symbol) {
					winner = null;
					break;
				}
			}

			if (winner != null) {
				return true;
			}
		}

		return false;
	}

	static function isDraw( cells: Array<String> )
		return Lambda.count(cells, function( c ) return switch c {
			case null: false;
			case other: true;
		}) == cells.length;
}
