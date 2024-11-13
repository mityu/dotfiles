import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddc-vim@~8.1.0/config";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): Promise<void> {
    args.contextBuilder.patchGlobal({
      ui: "native",
      backspaceCompletion: true,
      specialBufferCompletion: true,
      sources: ["lsp", "around"],
      sourceOptions: {
        _: {
          matchers: ["matcher_fuzzy"],
          sorters: ["sorter_fuzzy"],
          ignoreCase: true,
        },
        lsp: {
          mark: "lsp",
          forceCompletionPattern: "\.\w*|:\w*|->\w*",
          minAutoCompleteLength: 2,
          // sorters: ["sorter_lsp-kind"],
        },
        around: {
          mark: "around",
          minAutoCompleteLength: 3,
          maxItems: 20,
        },
        vim: {
          mark: "vim",
          minAutoCompleteLength: 3,
          maxItems: 20,
          isVolatile: true,
        },
      },
      sourceParams: {
        lsp: {
          enableResolveItem: true,
          enableAdditionalTextEdit: true,
          enableDisplayDetail: true,
        },
        around: {
          maxSize: 300,
        },
      },
      filterParams: {
        matcher_fuzzy: {
          splitMode: "word",
        },
      },
    });
    args.contextBuilder.patchFiletype("vim", { sources: ["vim", "around"] });
    return Promise.resolve();
  }
}
