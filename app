"""
Atlantic Recording Corporation - U.S. Top 50 Playlist Analytics Dashboard.

Run with: streamlit run app.py
"""

import os
import sys

import pandas as pd
import streamlit as st

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

import analysis as an
import feature_engineering as fe
import preprocessing
import visualizations as viz


st.set_page_config(
    page_title="Atlantic Top 50 Analytics",
    page_icon="A",
    layout="wide",
    initial_sidebar_state="expanded",
)

DATA_PATH = os.path.join(os.path.dirname(__file__), "data", "Atlantic_United_States.csv")


def inject_styles():
    st.markdown(
        """
        <style>
        @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap');

        :root {
            --ink: #17202a;
            --muted: #66727d;
            --aqua: #16877f;
            --coral: #e86d58;
            --line: rgba(23, 32, 42, .11);
            --glass: rgba(255, 255, 255, .76);
        }

        .stApp {
            background:
                radial-gradient(circle at 5% 0%, rgba(22, 135, 127, .16), transparent 30rem),
                radial-gradient(circle at 97% 12%, rgba(232, 109, 88, .14), transparent 26rem),
                linear-gradient(145deg, #f8fbf9 0%, #eaf2ef 52%, #faf6f1 100%);
            color: var(--ink);
        }

        .main .block-container {
            max-width: 1500px;
            padding: 2rem 3.25rem 4rem;
        }

        [data-testid="stSidebar"] {
            background: rgba(248, 251, 249, .9);
            border-right: 1px solid var(--line);
        }

        [data-testid="stSidebar"] > div:first-child { padding: 1.5rem 1.15rem; }
        [data-testid="stSidebar"] h2, [data-testid="stSidebar"] label { color: var(--ink); }
        [data-testid="stSidebar"] hr { border-color: var(--line); }

        .hero {
            position: relative;
            overflow: hidden;
            padding: 2rem 2.35rem 1.8rem;
            margin-bottom: 1.1rem;
            border: 1px solid rgba(255, 255, 255, .8);
            border-radius: 22px;
            background: linear-gradient(120deg, rgba(255,255,255,.82), rgba(255,255,255,.46));
            box-shadow: 0 18px 55px rgba(52, 76, 73, .1), inset 0 1px 0 rgba(255,255,255,.95);
            backdrop-filter: blur(18px);
        }

        .hero:after {
            content: "";
            position: absolute;
            width: 13rem;
            height: 13rem;
            right: -4rem;
            top: -6rem;
            border: 1px solid rgba(232, 109, 88, .34);
            border-radius: 50%;
            box-shadow: 0 0 0 22px rgba(232, 109, 88, .05), 0 0 0 44px rgba(232, 109, 88, .035);
        }

        .eyebrow {
            margin-bottom: .5rem;
            color: var(--aqua);
            font: 700 .7rem/1.2 'DM Sans', sans-serif;
            letter-spacing: .14em;
            text-transform: uppercase;
        }

        .hero h1 {
            position: relative;
            z-index: 1;
            max-width: 850px;
            margin: 0;
            color: var(--ink);
            font: 700 clamp(2.2rem, 4vw, 4.3rem)/.98 'Space Grotesk', sans-serif;
        }

        .hero p {
            position: relative;
            z-index: 1;
            max-width: 720px;
            margin: .9rem 0 0;
            color: var(--muted);
            font: 400 1rem/1.55 'DM Sans', sans-serif;
        }

        .signal-row { display: flex; flex-wrap: wrap; gap: .5rem; margin-top: 1.2rem; }
        .signal {
            padding: .38rem .68rem;
            border: 1px solid rgba(22, 135, 127, .2);
            border-radius: 999px;
            background: rgba(255,255,255,.62);
            color: #346c68;
            font: 600 .73rem/1 'DM Sans', sans-serif;
        }

        h1, h2, h3, [data-testid="stMetricLabel"], [data-testid="stMetricValue"],
        [data-testid="stMarkdownContainer"], .stCaption, button, input {
            font-family: 'DM Sans', sans-serif;
        }
        h2, h3 { font-family: 'Space Grotesk', sans-serif !important; color: var(--ink); }
        h2 { margin-top: .55rem; }

        [data-testid="stMetric"] {
            min-height: 7.7rem;
            padding: 1rem 1.05rem;
            border: 1px solid rgba(255,255,255,.82);
            border-radius: 15px;
            background: var(--glass);
            box-shadow: 0 10px 28px rgba(52, 76, 73, .07), inset 0 1px 0 rgba(255,255,255,.9);
            backdrop-filter: blur(14px);
        }

        [data-testid="stMetricLabel"] { color: var(--muted); font-weight: 600; }
        [data-testid="stMetricValue"] { color: var(--ink); font-family: 'Space Grotesk', sans-serif; }
        [data-testid="stMetricDelta"] { color: var(--aqua); }

        [data-testid="stTabs"] [role="tablist"] {
            gap: .25rem;
            padding: .25rem;
            border: 1px solid var(--line);
            border-radius: 13px;
            background: rgba(255,255,255,.4);
        }
        [data-testid="stTabs"] button {
            border-radius: 9px;
            color: var(--muted);
            font-weight: 600;
        }
        [data-testid="stTabs"] button[aria-selected="true"] { color: var(--aqua); background: rgba(255,255,255,.72); }
        [data-testid="stTabs"] [data-baseweb="tab-highlight"] { display: none; }

        .stPlotlyChart, [data-testid="stDataFrame"] {
            border: 1px solid rgba(255,255,255,.76);
            border-radius: 15px;
            background: rgba(255,255,255,.5);
            box-shadow: 0 10px 30px rgba(52, 76, 73, .06);
            overflow: hidden;
        }

        .section-note {
            margin: -.25rem 0 .85rem;
            color: var(--muted);
            font-size: .9rem;
        }

        @media (max-width: 800px) {
            .main .block-container { padding: 1rem .85rem 2.5rem; }
            .hero { padding: 1.5rem 1.25rem; border-radius: 18px; }
            .hero h1 { font-size: 2.35rem; }
        }
        </style>
        """,
        unsafe_allow_html=True,
    )


@st.cache_data
def load_data():
    raw = preprocessing.load_raw(DATA_PATH)
    clean_df = preprocessing.clean(raw)
    daily, song_summary, artist_summary = fe.engineer_all(clean_df)
    return daily, song_summary, artist_summary


def filter_data(daily, song_summary, date_range, artists, songs, position_range, album_types):
    """Apply the dashboard scope once so every view uses the same rows."""
    d = daily[
        (daily["date"] >= pd.Timestamp(date_range[0]))
        & (daily["date"] <= pd.Timestamp(date_range[1]))
        & (daily["position"] >= position_range[0])
        & (daily["position"] <= position_range[1])
        & (daily["album_type"].isin(album_types))
    ]
    if artists:
        d = d[d["artist"].isin(artists)]
    if songs:
        d = d[d["song"].isin(songs)]

    keys_in_scope = set(map(tuple, d[["song", "artist"]].drop_duplicates().values))
    s = song_summary[
        song_summary.apply(lambda row: (row["song"], row["artist"]) in keys_in_scope, axis=1)
    ]
    return d, s


def render_kpis(daily_f, song_summary_f, artist_summary_f):
    kpis = an.compute_kpis(daily_f, song_summary_f, artist_summary_f)
    cols = st.columns(6)
    cols[0].metric("Chart days / song", f'{kpis["avg_days_on_chart"]:.1f}')
    cols[1].metric("Average position", f'{kpis["avg_rank"]:.1f}')
    cols[2].metric("Rank volatility", f'{kpis["avg_rank_volatility"]:.1f}')
    cols[3].metric("Popularity score", f'{kpis["avg_popularity"]:.1f}')
    cols[4].metric("Leading artist", kpis["top_artist_name"])
    cols[5].metric("Explicit share", f'{kpis["explicit_content_share"]:.1f}%')


def render_sidebar(daily):
    st.sidebar.header("Scope the analysis")
    st.sidebar.caption("Every chart and headline metric updates from these filters.")
    min_d, max_d = daily["date"].min().date(), daily["date"].max().date()
    date_range = st.sidebar.date_input(
        "Date range", value=(min_d, max_d), min_value=min_d, max_value=max_d
    )
    if len(date_range) != 2:
        date_range = (min_d, max_d)

    all_artists = sorted(daily["artist"].unique())
    artists = st.sidebar.multiselect("Artist", all_artists)
    song_options = sorted(
        daily.loc[daily["artist"].isin(artists), "song"].unique()
        if artists else daily["song"].unique()
    )
    songs = st.sidebar.multiselect("Song", song_options)
    position_range = st.sidebar.slider("Chart position", 1, 50, (1, 50))
    album_types = st.sidebar.multiselect(
        "Release type",
        sorted(daily["album_type"].unique()),
        default=sorted(daily["album_type"].unique()),
    )

    with st.sidebar.expander("About the data"):
        st.caption(
            f"{daily['date'].nunique():,} observed snapshots · "
            f"{len(daily):,} cleaned entries · "
            f"{daily['artist'].nunique():,} artists"
        )
        st.caption(
            f"{min_d.strftime('%d %b %Y')} – {max_d.strftime('%d %b %Y')}. "
            "Calendar gaps are left as genuine gaps; no rankings are invented."
        )

    return date_range, artists, songs, position_range, album_types


def section_note(text):
    st.markdown(f'<p class="section-note">{text}</p>', unsafe_allow_html=True)


def render_overview(daily_f, song_summary_f):
    st.subheader("What changed in the selected scope?")
    section_note("Use this as the executive readout: movement, reach, and the songs with the strongest staying power.")
    left, right = st.columns([1.45, 1])
    with left:
        st.plotly_chart(
            viz.entries_exits_chart(an.daily_entries_exits(daily_f)),
            use_container_width=True,
        )
    with right:
        st.markdown("#### Longest-running songs")
        table = (
            song_summary_f.sort_values(["days_on_chart", "average_rank"], ascending=[False, True])
            .head(8)[["song", "artist", "days_on_chart", "average_rank", "best_rank"]]
            .rename(columns={
                "song": "Song", "artist": "Artist", "days_on_chart": "Chart days",
                "average_rank": "Avg position", "best_rank": "Best position",
            })
        )
        st.dataframe(table, hide_index=True, use_container_width=True)


def render_songs(daily_f, song_summary_f):
    st.subheader("Song performance")
    section_note("Compare a song's trajectory with its overall longevity and ranking profile.")
    options = song_summary_f[["song", "artist"]].drop_duplicates().to_records(index=False).tolist()
    labels = [f"{song} — {artist}" for song, artist in options]
    choice = st.selectbox("Song to inspect", labels)
    song_name, artist_name = options[labels.index(choice)]
    row = song_summary_f[
        (song_summary_f["song"] == song_name) & (song_summary_f["artist"] == artist_name)
    ].iloc[0]

    st.plotly_chart(
        viz.song_trend_chart(daily_f, song_name, artist_name),
        use_container_width=True,
    )
    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Best position", int(row["best_rank"]))
    c2.metric("Average position", f'{row["average_rank"]:.1f}')
    c3.metric("Chart days", int(row["days_on_chart"]))
    c4.metric("Rank volatility", f'{row["rank_volatility"]:.1f}')


def render_artists(artist_summary_f):
    st.subheader("Artist reach")
    section_note("The dominance index blends chart presence, breadth, ranking strength, and popularity.")
    left, right = st.columns([1.25, 1])
    with left:
        st.plotly_chart(viz.artist_leaderboard_chart(artist_summary_f), use_container_width=True)
    with right:
        table = artist_summary_f.head(15)[
            ["artist", "unique_songs", "total_chart_days", "average_position", "dominance_index"]
        ].rename(columns={
            "artist": "Artist", "unique_songs": "Songs", "total_chart_days": "Chart days",
            "average_position": "Avg position", "dominance_index": "Index",
        })
        st.dataframe(table, hide_index=True, use_container_width=True)


def render_content(daily_f, song_summary_f):
    st.subheader("Audience and content signals")
    section_note("These comparisons are descriptive and correlational, not causal.")
    left, right = st.columns(2)
    with left:
        corr = an.popularity_position_correlation(daily_f)
        st.metric("Popularity / position correlation", f"{corr:.3f}")
        st.plotly_chart(viz.popularity_rank_scatter(daily_f), use_container_width=True)
    with right:
        st.plotly_chart(
            viz.explicit_comparison_chart(an.explicit_vs_clean(song_summary_f)),
            use_container_width=True,
        )
    st.dataframe(an.popularity_by_tier(daily_f), use_container_width=True)


def render_catalog(song_summary_f):
    st.subheader("Catalog signals")
    section_note("Explore whether duration or album size moves with popularity or longevity.")
    left, right = st.columns(2)
    with left:
        st.plotly_chart(viz.duration_scatter(song_summary_f), use_container_width=True)
    with right:
        st.plotly_chart(viz.album_size_scatter(song_summary_f), use_container_width=True)
    correlations = {
        **an.duration_correlations(song_summary_f),
        **an.album_size_correlations(song_summary_f),
    }
    correlation_table = pd.DataFrame(
        {"Signal": list(correlations.keys()), "Correlation": list(correlations.values())}
    )
    st.dataframe(correlation_table, hide_index=True, use_container_width=True)


def main():
    inject_styles()
    daily, song_summary, _ = load_data()
    date_range, artists, songs, position_range, album_types = render_sidebar(daily)
    daily_f, song_summary_f = filter_data(
        daily, song_summary, date_range, artists, songs, position_range, album_types
    )

    st.markdown(
        f"""
        <section class="hero">
            <div class="eyebrow">Atlantic Recording Corporation / U.S. Top 50</div>
            <h1>Where the playlist tells its story.</h1>
            <p>Read momentum, staying power, artist reach, and catalog signals from every observed chart snapshot.</p>
            <div class="signal-row">
                <span class="signal">{len(daily_f):,} entries in scope</span>
                <span class="signal">{daily_f['date'].nunique():,} observed snapshots</span>
                <span class="signal">Filter-aware analysis</span>
            </div>
        </section>
        """,
        unsafe_allow_html=True,
    )

    if daily_f.empty or song_summary_f.empty:
        st.warning("No data matches the current filters. Adjust the filters in the sidebar.")
        return

    artist_summary_f = fe.build_artist_summary(daily_f, song_summary_f)
    render_kpis(daily_f, song_summary_f, artist_summary_f)
    st.divider()

    tabs = st.tabs(["Overview", "Songs", "Artists", "Audience & content", "Catalog signals"])
    with tabs[0]:
        render_overview(daily_f, song_summary_f)
    with tabs[1]:
        render_songs(daily_f, song_summary_f)
    with tabs[2]:
        render_artists(artist_summary_f)
    with tabs[3]:
        render_content(daily_f, song_summary_f)
    with tabs[4]:
        render_catalog(song_summary_f)

    with st.expander("Methodology and limitations"):
        st.write(
            "The source contains daily U.S. Top 50 snapshots. The pipeline removes one duplicated "
            "100-row snapshot, preserves genuine calendar gaps, and computes metrics from observed "
            "rows only. The dominance index uses equal weights across presence, breadth, ranking "
            "strength, and popularity. All relationships shown here are correlational."
        )


if __name__ == "__main__":
    main()
