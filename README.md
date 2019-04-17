# vim-golinter

An asynchronous Golint for Vim.

Available linter

- [GolangCI-Lint](https://github.com/golangci/golangci-lint)

![Realtime style check](./assets/vim-golinter.gif)

## Invoke manually

Open Go file and just execute `:Golinter`.

## Automatically lint on save

```viml
autocmd BufWritePost *.ts,*.tsx call golinter#run()
```

## License

New BSD License
