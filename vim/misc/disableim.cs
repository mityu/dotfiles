using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public static class DisableIM {
    private static readonly int IMC_GETOPENSTATUS = 5;
    private static readonly int IMC_SETOPENSTATUS = 6;
    private static readonly uint WM_IME_CONTROL = 0x0283;

    [DllImport("user32.dll")]
    private static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    private static extern long SendMessage(
            IntPtr hWnd, uint Msg, int wParam, int lParam);

    [DllImport("Imm32.dll")]
    private static extern IntPtr ImmGetDefaultIMEWnd(IntPtr param);

    private static void showError(String msg) {
        MessageBox.Show(msg, "DisableIM", MessageBoxButtons.OK, MessageBoxIcon.Error);
    }

    [STAThread]
    public static void Main() {
        IntPtr hwnd = GetForegroundWindow();
        if (hwnd == IntPtr.Zero) {
            // showError("Internal error: Got NULL window handle.");
            return;
        }

        IntPtr ime = ImmGetDefaultIMEWnd(hwnd);
        if (ime == IntPtr.Zero) {
            // showError("Internal error: Got NULL ime handle.");
            return;
        }

        long status = SendMessage(ime, WM_IME_CONTROL, IMC_GETOPENSTATUS, 0);
        if (status != 0)
            SendMessage(ime, WM_IME_CONTROL, IMC_SETOPENSTATUS, 0);
    }
}
