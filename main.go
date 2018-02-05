package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"sync"
)

type Router struct {
	IP       string
	Port     uint32
	Status   string
	Auth     string
	Type     string
	RadioOff string
	Hidden   string
	BSSID    string
	SSID     string
	Sec      string
	Key      string
	WPS      string
	LANIP    string
	LANMask  string
	WANIP    string
	WANMask  string
	WANGate  string
	DNS      string
	End      bool
}

var scanner = bufio.NewScanner(os.Stdin)
var wg sync.WaitGroup
var c chan string = make(chan string)

var threads = flag.Int("t", 2, "count of threads")
var debug = flag.Bool("d", false, "debug")

func inet_aton(ip string) (ip_int uint32) {
	ip_byte := net.ParseIP(ip).To4()
	for i := 0; i < len(ip_byte); i++ {
		ip_int |= uint32(ip_byte[i])
		if i < 3 {
			ip_int <<= 8
		}
	}
	return
}

func rsscanCheck() {
	for {
		rsscanCommand := exec.Command("./rsscan")
		rsscanCommand.Env = append(os.Environ(), "LD_LIBRARY_PATH=.")
		rsscanStdin, err := rsscanCommand.StdinPipe() //Creating writable stream to rsscan input
		if err != nil {
			log.Fatal(err)
		}
		rsscanCommand.Stderr = os.Stderr
		rsscanStdout, err := rsscanCommand.StdoutPipe() //Creating readable stream for read rsscan output
		if err != nil {
			log.Fatal(err)
		}
		rsscanScanner := bufio.NewScanner(rsscanStdout)

		rsscanCommand.Start()
		for {
			task := <-c //Load router ip from channel
			if *debug {
				fmt.Fprintln(os.Stderr, "New task: ", task)
			}
			routerAddr := strings.Split(task, ":")
			if len(routerAddr) != 2 {
				continue
			}
			if net.ParseIP(routerAddr[0]) == nil {
				continue
			}
			port, err := strconv.ParseUint(routerAddr[1], 10, 32)
			if err != nil {
				fmt.Fprintln(os.Stderr, "error:", err)
				continue
			}
			wg.Add(1)
			router := new(Router)
			router.IP = routerAddr[0]
			routerIPInt := inet_aton(routerAddr[0])

			router.Port = uint32(port)
			io.WriteString(rsscanStdin, fmt.Sprint(routerIPInt)+" "+fmt.Sprint(port)+"\n") //Write router ip to rsscan
			for rsscanScanner.Scan() {                                                     //Read answer from rsscan
				line := rsscanScanner.Text()
				if line == "$$$end" {
					router.End = true
					break
				}
				if *debug {
					fmt.Fprintln(os.Stderr, "dbg:", router.IP, line)
				}
				routerArr := strings.SplitN(line, ": ", 2)
				if len(routerArr) == 2 {
					switch routerArr[0] {
					case "Status":
						router.Status = routerArr[1]
					case "Auth":
						router.Auth = routerArr[1]
					case "Type":
						router.Type = routerArr[1]
					case "RadioOff":
						router.RadioOff = routerArr[1]
					case "Hidden":
						router.Hidden = routerArr[1]
					case "BSSID":
						router.BSSID = routerArr[1]
					case "SSID":
						router.SSID = routerArr[1]
					case "Sec":
						router.Sec = routerArr[1]
					case "Key":
						router.Key = routerArr[1]
					case "WPS":
						router.WPS = routerArr[1]
					case "LANIP":
						router.LANIP = routerArr[1]
					case "LANMask":
						router.LANMask = routerArr[1]
					case "WANIP":
						router.WANIP = routerArr[1]
					case "WANMask":
						router.WANMask = routerArr[1]
					case "WANGate":
						router.WANGate = routerArr[1]
					case "DNS":
						router.DNS = routerArr[1]
					}
				}
			}
			routerMarshalled, err := json.Marshal(router) //Convert struct to JSON
			if err != nil {
				fmt.Fprintln(os.Stderr, "error:", err)
			} else {
				fmt.Printf("%s\n", string(routerMarshalled))
			}
			wg.Done()
			if !router.End {
				if *debug {
					fmt.Fprintln(os.Stderr, "ERROR, restarting rsscan")
				}
				rsscanCommand.Process.Kill()
				rsscanCheck()
			}
		}
	}
}

func main() {
	flag.Parse()
	for i := 0; i < *threads; i++ {
		go rsscanCheck()
	}
	stringsScanned := 0
	for scanner.Scan() {
		host := scanner.Text()
		c <- host

		stringsScanned++
		if stringsScanned%100 == 0 {
			fmt.Fprintln(os.Stderr, "Current line: ", stringsScanned)
		}

	}
	wg.Wait()
	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}
